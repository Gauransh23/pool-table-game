extends SceneTree

# Behavioral regression coverage for deliberate aim gestures. This deliberately
# exercises Viewport input routing so GUI controls get first chance to handle a
# press, rather than calling GameController's private input method directly.
var failures: Array[String] = []
var game: GameController
var viewport: Viewport
var session_file := "/tmp/longrail-aim-controls-%d.json" % Time.get_ticks_usec()

func require(condition: bool, description: String) -> void:
	print("%s: %s" % ["PASS" if condition else "FAIL", description])
	if not condition:
		failures.append(description)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	# The headless display is 64x64; declare this input fixture's logical canvas.
	root.content_scale_size = Vector2i(1600, 900)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	game = load("res://scenes/main.tscn").instantiate() as GameController
	game.session_path = session_file
	root.add_child(game)
	await game.table_view._camera_tween.finished
	game.set_process(false)
	game.hud.hide_menu()
	game._new_rack(false)
	viewport = game.get_viewport()

	var world_points := [Vector2(-0.9, 0.35), Vector2(0.65, 0.30), Vector2(-0.2, -0.3)]
	var first := screen_for_table(world_points[0])
	var second := screen_for_table(world_points[1])
	var third := screen_for_table(world_points[2])
	var cloth_valid := true
	for index in range(world_points.size()):
		var world_point: Vector2 = world_points[index]
		var screen_point: Vector2 = [first, second, third][index]
		cloth_valid = cloth_valid and not game.table.outside_table(world_point) and game.table.pocket_at(world_point) < 0 and is_inside_viewport(screen_point)
	require(cloth_valid, "camera projects test points into the current viewport size %s" % viewport.get_visible_rect().size)

	if cloth_valid:
		await test_unpressed_motion(first)
		await test_right_drag(first, second)
		await test_hud_origin_drag(second)
		await test_left_drag_and_release(first, second)
		await test_placement_click(third)
		await test_keyboard_fine_aim()
		await test_mouse_fine_aim(first, second)
		await test_cancellation(first, second, third, "menu")
		await test_cancellation(first, second, third, "new rack")
		await test_cancellation(first, second, third, "undo")
		await test_cancellation(first, second, third, "camera")
		await test_escape_cancels(first, second, third)
		await test_focus_loss_cancels(first, second, third)
		await test_shot_cancels(first, second, third)

	await cleanup()
	print("AIM CONTROLS: %d failure(s)" % failures.size())
	quit(1 if not failures.is_empty() else 0)

func screen_for_table(point: Vector2) -> Vector2:
	return game.table_view.camera().unproject_position(Vector3(point.x, BallState.RADIUS, point.y))

func is_inside_viewport(point: Vector2) -> bool:
	var rect := viewport.get_visible_rect()
	return point.x >= 0.0 and point.y >= 0.0 and point.x < rect.size.x and point.y < rect.size.y

func send_mouse_button(point: Vector2, pressed: bool, button: int = MOUSE_BUTTON_LEFT, fine: bool = false) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.button_index = button
	event.pressed = pressed
	event.shift_pressed = fine
	viewport.push_input(event, true)
	await process_frame

func send_motion(point: Vector2, buttons: int = 0) -> void:
	var event := InputEventMouseMotion.new()
	event.position = point
	event.button_mask = buttons
	viewport.push_input(event, true)
	await process_frame

func reset_aim(direction: Vector2 = Vector2.RIGHT) -> void:
	game.aim_direction = direction
	game._refresh_aim()

func aim_direction_expected_at(point: Vector2) -> Vector2:
	return (game.table_view.project_mouse_to_table(point, BallState.RADIUS) - game._cue_ball().position).normalized()

func test_unpressed_motion(point: Vector2) -> void:
	reset_aim(Vector2.RIGHT)
	await send_motion(point)
	require(game.aim_direction.is_equal_approx(Vector2.RIGHT), "unpressed pointer motion preserves retained aim")

func test_right_drag(start: Vector2, finish: Vector2) -> void:
	reset_aim(Vector2.RIGHT)
	await send_mouse_button(start, true, MOUSE_BUTTON_RIGHT)
	await send_motion(finish, MOUSE_BUTTON_MASK_RIGHT)
	await send_mouse_button(finish, false, MOUSE_BUTTON_RIGHT)
	require(game.aim_direction.is_equal_approx(Vector2.RIGHT), "right-button drag does not change aim")

func test_hud_origin_drag(cloth_point: Vector2) -> void:
	reset_aim(Vector2.RIGHT)
	var slider_rect: Rect2 = game.hud._power.get_global_rect()
	var hud_point := slider_rect.get_center()
	var in_hud := game.hud._power.get_global_rect().has_point(hud_point)
	require(in_hud and is_inside_viewport(hud_point), "HUD slider origin is visible for routed input")
	if not in_hud:
		return
	await send_mouse_button(hud_point, true)
	await send_motion(cloth_point, MOUSE_BUTTON_MASK_LEFT)
	await send_mouse_button(cloth_point, false)
	require(game.aim_direction.is_equal_approx(Vector2.RIGHT), "HUD-origin drag onto cloth does not acquire or change aim")

func test_left_drag_and_release(start: Vector2, finish: Vector2) -> void:
	reset_aim(Vector2.RIGHT)
	var expected := aim_direction_expected_at(finish)
	await send_mouse_button(start, true)
	await send_motion(finish, MOUSE_BUTTON_MASK_LEFT)
	require(game.aim_direction.is_equal_approx(expected), "left press on cloth followed by held drag updates aim (expected %s, got %s)" % [expected, game.aim_direction])
	var retained := game.aim_direction
	var hud_point: Vector2 = game.hud._power.get_global_rect().get_center()
	await send_mouse_button(hud_point, false)
	await send_motion(start, MOUSE_BUTTON_MASK_LEFT)
	require(game.aim_direction.is_equal_approx(retained), "GUI-consumed release cancels gesture before held motion returns to cloth")
	await send_mouse_button(start, true)
	await send_motion(finish, MOUSE_BUTTON_MASK_LEFT)
	retained = game.aim_direction
	await send_mouse_button(Vector2(-20.0, -20.0), false)
	require(game.aim_direction.is_equal_approx(retained), "release outside viewport retains the last aimed line")

func test_placement_click(point: Vector2) -> void:
	reset_aim(Vector2.RIGHT)
	game._placing = true
	var expected_position := game.table_view.project_mouse_to_table(point, BallState.RADIUS)
	await send_mouse_button(point, true)
	await send_mouse_button(point, false)
	require(not game._placing and game._cue_ball().position.distance_to(expected_position) < 0.01,
		"placement click places the cue ball at the clicked clear cloth point")
	require(game.aim_direction.is_equal_approx(Vector2.RIGHT), "placement click places without acquiring a new aim gesture")
	game._new_rack(false)

func test_keyboard_fine_aim() -> void:
	reset_aim(Vector2.RIGHT)
	var key := InputEventKey.new()
	key.keycode = KEY_LEFT
	key.pressed = true
	viewport.push_input(key, true)
	await process_frame
	require(not game.aim_direction.is_equal_approx(Vector2.RIGHT), "left/right fine aim works while idle")
	game._placing = true
	reset_aim(Vector2.RIGHT)
	key = InputEventKey.new()
	key.keycode = KEY_LEFT
	key.pressed = true
	viewport.push_input(key, true)
	await process_frame
	require(game.aim_direction.is_equal_approx(Vector2.RIGHT), "keyboard fine aim is ignored during cue placement")
	game._placing = false

func start_drag(start: Vector2, finish: Vector2) -> void:
	await send_mouse_button(start, true)
	await send_motion(finish, MOUSE_BUTTON_MASK_LEFT)

func finish_drag(point: Vector2) -> void:
	await send_mouse_button(point, false)

func test_cancellation(start: Vector2, finish: Vector2, after: Vector2, action: String) -> void:
	game._new_rack(false)
	reset_aim(Vector2.RIGHT)
	await start_drag(start, finish)
	var before_cancel := game.aim_direction
	match action:
		"menu":
			game.hud.menu_requested.emit()
			game.hud.hide_menu()
		"new rack": game._new_rack(false)
		"undo":
			game._undo = game._copy_balls(game.balls)
			game._undo_shot()
		"camera": game._toggle_view()
	var after_action := game.aim_direction
	await send_motion(after, MOUSE_BUTTON_MASK_LEFT)
	var ignored := game.aim_direction.is_equal_approx(after_action)
	await finish_drag(after)
	require(not before_cancel.is_equal_approx(Vector2.RIGHT), "%s scenario begins with an active aimed drag" % action)
	require(ignored, "%s cancels the active drag so later held motion is ignored" % action)
	if action == "menu":
		game.hud.hide_menu()
	if action == "camera":
		# Restore the default camera before projecting later test points.
		game._toggle_view()
		await game.table_view._camera_tween.finished

func test_focus_loss_cancels(start: Vector2, finish: Vector2, after: Vector2) -> void:
	game._new_rack(false)
	reset_aim(Vector2.RIGHT)
	await start_drag(start, finish)
	var before_cancel := game.aim_direction
	root.propagate_notification(Window.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	var after_action := game.aim_direction
	await send_motion(after, MOUSE_BUTTON_MASK_LEFT)
	var ignored := game.aim_direction.is_equal_approx(after_action)
	await finish_drag(after)
	require(not before_cancel.is_equal_approx(Vector2.RIGHT), "focus-loss scenario begins with an active aimed drag")
	require(ignored, "window focus loss cancels the active drag")

func test_escape_cancels(start: Vector2, finish: Vector2, after: Vector2) -> void:
	game._new_rack(false)
	reset_aim(Vector2.RIGHT)
	await start_drag(start, finish)
	var before_cancel := game.aim_direction
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	viewport.push_input(escape, true)
	await process_frame
	var opened := game.hud.menu_visible()
	await send_motion(after, MOUSE_BUTTON_MASK_LEFT)
	escape = InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	viewport.push_input(escape, true)
	await process_frame
	var closed := not game.hud.menu_visible()
	var after_close := game.aim_direction
	await send_motion(finish, MOUSE_BUTTON_MASK_LEFT)
	var ignored_after_close := game.aim_direction.is_equal_approx(after_close)
	await finish_drag(finish)
	require(opened and closed, "Escape opens and closes the menu during an active drag")
	require(not before_cancel.is_equal_approx(Vector2.RIGHT), "Escape scenario begins with an active aimed drag")
	require(ignored_after_close, "Escape menu open/close cancels the drag before held motion resumes")

func test_shot_cancels(start: Vector2, finish: Vector2, after: Vector2) -> void:
	game._new_rack(false)
	reset_aim(Vector2.RIGHT)
	await start_drag(start, finish)
	var before_cancel := game.aim_direction
	game._on_shoot_requested(.42, Vector2.ZERO)
	var after_action := game.aim_direction
	await send_motion(after, MOUSE_BUTTON_MASK_LEFT)
	var ignored := game.aim_direction.is_equal_approx(after_action)
	await finish_drag(after)
	await create_timer(0.13).timeout
	require(not before_cancel.is_equal_approx(Vector2.RIGHT), "shot-cancel scenario begins with an active aimed drag")
	require(ignored, "starting a shot cancels the active drag")
	game._shot_in_motion = false

func cleanup() -> void:
	if is_instance_valid(game):
		game.table_view.cancel_stroke()
		game.queue_free()
		game = null
		viewport = null
		await process_frame
	for path in [session_file, session_file + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)

func test_mouse_fine_aim(first: Vector2, second: Vector2) -> void:
	for point in [first, second]:
		for heading in [0.0, 1.4, PI - 0.0001]:
			reset_aim(Vector2.from_angle(heading))
			var original := game.aim_direction
			await send_mouse_button(point, true, MOUSE_BUTTON_LEFT, true)
			require(absf(original.angle_to(game.aim_direction)) < 1e-7, "fine press retains heading without pointer snap")
			var bounded := true
			var moved := false
			for sign_value in [1.0, -1.0]:
				for index in range(100):
					var before := game.aim_direction
					var event := InputEventMouseMotion.new()
					event.position = point
					event.relative = Vector2(sign_value, 0.0)
					event.button_mask = MOUSE_BUTTON_MASK_LEFT
					# Modifier intentionally absent: mode is latched at press.
					viewport.push_input(event, true)
					var change := before.angle_to(game.aim_direction)
					bounded = bounded and absf(change) <= deg_to_rad(0.005) and change * sign_value > 0.0
					moved = moved or absf(change) > 1e-7
				await process_frame
			require(bounded and moved, "100 positive/negative mouse increments stay within 0.005 degrees at heading %.3f" % heading)
			require(absf(original.angle_to(game.aim_direction)) <= deg_to_rad(0.002), "reversed fine increments restore physical aim within 0.002 degrees")
			await send_mouse_button(point, false)
			var retained := game.aim_direction
			await send_motion(second, MOUSE_BUTTON_MASK_LEFT)
			require(absf(retained.angle_to(game.aim_direction)) < 1e-7, "fine release cancels held motion")
	await send_mouse_button(first, true, MOUSE_BUTTON_LEFT, true)
	root.propagate_notification(Window.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	var retained := game.aim_direction
	await send_motion(second, MOUSE_BUTTON_MASK_LEFT)
	require(absf(retained.angle_to(game.aim_direction)) < 1e-7 and not game._stroke_pending, "fine focus loss retains aim and never fires")
	await send_mouse_button(second, false)
