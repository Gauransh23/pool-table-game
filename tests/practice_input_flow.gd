extends SceneTree

# Exercise the same scene, camera and GUI event route used by practice play.
# Each fixture has its own viewport and save, so it never touches the live game.
var game: GameController
var viewport: Viewport
var owns_viewport := false
var failures: Array[String] = []
var checks := 0
var session_file := ""


func _initialize() -> void:
	call_deferred("run")


func require(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		printerr("FAIL: " + description)


func run() -> void:
	for size in [Vector2i(1100, 700), Vector2i(1600, 900), Vector2i(1920, 1080)]:
		await create_fixture(size)
		await test_layout_and_reachable_cloth(size)
		await test_mouse_transaction(size)
		if size == Vector2i(1600, 900): await test_resize_retains_aim()
		await cleanup()
	# Initial Tab traversal belongs to a Window, not an unattached SubViewport.
	await create_fixture(Vector2i(1100, 700), true)
	await test_keyboard_transaction()
	await cleanup()
	print("PRACTICE INPUT FLOW: %d checks, %d failure(s)" % [checks, failures.size()])
	call_deferred("finish")


func finish() -> void:
	quit(1 if not failures.is_empty() else 0)


func create_fixture(size: Vector2i, window_fixture: bool = false) -> void:
	owns_viewport = not window_fixture
	if window_fixture:
		viewport = root
		root.size = size
		# Give the headless Window a real input canvas; native resize is rendered
		# separately by capture_preview.gd using the project's disabled stretch.
		root.content_scale_size = size
		root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	else:
		var child := SubViewport.new()
		child.size = size
		root.add_child(child)
		viewport = child
	game = load("res://scenes/main.tscn").instantiate() as GameController
	session_file = "/tmp/longrail-input-flow-%d.json" % Time.get_ticks_usec()
	game.session_path = session_file
	viewport.add_child(game)
	# Input/state fixtures do not ask the headless Dummy driver to mix samples.
	# Audio event delivery is independently covered by audio_contacts.gd.
	game._audio.enabled = false
	game.set_process(false)
	game.hud.hide_menu()
	await game.table_view._camera_tween.finished
	game._new_rack(false)
	for frame in range(3):
		await process_frame


func test_layout_and_reachable_cloth(size: Vector2i) -> void:
	var panel: Control = game.hud._power.get_parent().get_parent()
	var panel_rect := panel.get_global_rect()
	var visible := viewport.get_visible_rect()
	require(visible.encloses(panel_rect), "%s: all HUD controls fit inside the viewport" % size)
	for overhead in [true, false]:
		game.table_view.set_overhead(overhead)
		await game.table_view._camera_tween.finished
		for frame in range(2):
			await process_frame
		for point in game.table.cloth_outline():
			var screen := screen_for_table(point)
			require(visible.has_point(screen) and not panel_rect.has_point(screen),
				"%s view=%s: cloth boundary %s remains visible outside HUD" % [size, overhead, point])
		var target := Vector2(1.1, 0.55)
		var click := screen_for_table(target)
		var expected := (target - game._cue_ball().position).normalized()
		game.aim_direction = Vector2.RIGHT
		await mouse_button(click, true)
		require(game._aim_gesture and game.aim_direction.distance_to(expected) < 1.0e-5,
			"%s view=%s: formerly covered cloth starts aiming" % [size, overhead])
		await mouse_button(click, false)
	game.table_view.set_overhead(true)
	await game.table_view._camera_tween.finished


func test_mouse_transaction(size: Vector2i) -> void:
	game._new_rack(false)
	game.hud._power.value = 0.20
	var start := screen_for_table(Vector2(-0.9, 0.35))
	var finish := screen_for_table(Vector2(0.65, 0.30))
	await mouse_button(start, true)
	await mouse_motion(finish, MOUSE_BUTTON_MASK_LEFT)
	await mouse_button(finish, false)
	var retained := game.aim_direction
	require(not game._aim_gesture and not retained.is_equal_approx(Vector2.RIGHT),
		"%s: cloth release retains a deliberately acquired line" % size)
	await mouse_motion(start)
	var rect := game.hud._power.get_global_rect()
	var power_start := Vector2(rect.position.x + rect.size.x * 0.25, rect.get_center().y)
	var power_end := Vector2(rect.position.x + rect.size.x * 0.65, rect.get_center().y)
	await mouse_motion(power_start)
	await mouse_button(power_start, true)
	await mouse_motion(power_end, MOUSE_BUTTON_MASK_LEFT)
	await mouse_button(power_end, false)
	require(game.power > 0.30 and is_equal_approx(game.power, game.hud._power.value),
		"%s: routed slider drag changes actual shot power" % size)
	require(game.aim_direction.is_equal_approx(retained), "%s: GUI use preserves retained aim" % size)
	var shoot := game.hud._shoot.get_global_rect().get_center()
	await mouse_motion(shoot)
	await mouse_button(shoot, true)
	await mouse_button(shoot, false)
	await create_timer(0.20).timeout
	require(game._strokes == 1 and game._shot_in_motion, "%s: button fires exactly one committed shot" % size)
	require(game.aim_direction.is_equal_approx(retained), "%s: shot retains its acquired heading" % size)
	settle_shot()
	require(not game._shot_in_motion, "%s: the shot settles and practice becomes ready" % size)
	game._undo_shot()
	require(game._strokes == 0 and not game._shot_in_motion, "%s: Undo restores practice" % size)


func test_keyboard_transaction() -> void:
	game._new_rack(false)
	viewport.gui_release_focus()
	await key(KEY_TAB)
	require(viewport.gui_get_focus_owner() == game.hud._power, "Tab reaches the power slider with visible focus")
	var heading := game.aim_direction
	var power_before := game.power
	await key(KEY_RIGHT)
	require(game.power > power_before, "focused power slider responds to arrow keys")
	require(game.aim_direction.is_equal_approx(heading), "power arrows do not also rotate table aim")
	await key(KEY_TAB)
	require(viewport.gui_get_focus_owner() == game.hud._spin, "Tab reaches tip position")
	await key(KEY_UP)
	require(game.spin.y > 0.0 and game.spin == game.hud.selected_spin, "tip arrows update the physical follow offset")
	var spin_before := game.spin
	await key(KEY_RIGHT, true)
	require(game.spin.x > spin_before.x and game.spin.x - spin_before.x < 0.01, "Shift gives fine keyboard tip adjustment")
	await key(KEY_HOME)
	require(game.spin == Vector2.ZERO, "Home centers the selected tip")
	await key(KEY_ESCAPE)
	require(viewport.gui_get_focus_owner() == null and not game.hud.menu_visible(), "Escape returns from a control to table aim")
	var power_after := game.power
	await key(KEY_LEFT)
	require(not game.aim_direction.is_equal_approx(heading) and game.power == power_after, "table arrows fine-aim without changing power")
	await key(KEY_P)
	require(viewport.gui_get_focus_owner() == game.hud._power, "P selects the power control")
	await key(KEY_ESCAPE)
	await key(KEY_S)
	require(viewport.gui_get_focus_owner() == game.hud._spin, "S selects tip position")
	await key(KEY_ESCAPE)
	await key(KEY_ESCAPE)
	require(game.hud.menu_visible() and viewport.gui_get_focus_owner() != null, "keyboard opens a focused practice menu")
	for tab in range(5):
		await key(KEY_TAB)
		var owner := viewport.gui_get_focus_owner()
		require(owner != null and game.hud._overlay.is_ancestor_of(owner), "menu Tab stays inside the menu")
	await key(KEY_ESCAPE)
	require(not game.hud.menu_visible(), "Escape resumes practice from the menu")
	# Enter activates the focused button through the GUI route.
	await key(KEY_P)
	for tab in range(10):
		if viewport.gui_get_focus_owner() == game.hud._shoot:
			break
		await key(KEY_TAB)
	require(viewport.gui_get_focus_owner() == game.hud._shoot, "Tab reaches Take Shot")
	await key(KEY_ENTER)
	await create_timer(0.20).timeout
	require(game._strokes == 1 and game._shot_in_motion, "Enter commits one keyboard-selected shot")
	settle_shot()
	await key(KEY_U)
	require(game._strokes == 0, "keyboard Undo restores the shot")
	await key(KEY_P)
	await key(KEY_SPACE)
	await create_timer(0.20).timeout
	require(game._strokes == 1 and game._shot_in_motion, "Space still shoots once after keyboard power selection")
	settle_shot()
	await key(KEY_U)
	# A scratch must not strand a keyboard-only player.
	var cue := game._cue_ball()
	cue.phase = BallState.Phase.POCKETED
	cue.height = -0.18
	cue.pocket_id = 0
	game._placing = true
	game._last_aim_state.clear()
	game._refresh_aim()
	viewport.gui_release_focus()
	var retained := game.aim_direction
	await key(KEY_RIGHT)
	await key(KEY_ENTER)
	require(not game._placing and cue.is_on_table(), "arrows and Enter restore the cue ball after a scratch")
	require(game.aim_direction.is_equal_approx(retained), "keyboard placement does not change retained aim")


func test_resize_retains_aim() -> void:
	var start := screen_for_table(Vector2(-0.9, 0.35))
	var finish := screen_for_table(Vector2(0.65, 0.30))
	await mouse_button(start, true)
	await mouse_motion(finish, MOUSE_BUTTON_MASK_LEFT)
	var retained := game.aim_direction
	viewport.size = Vector2i(1100, 700)
	for frame in range(3): await process_frame
	require(not game._aim_gesture and game.aim_direction.is_equal_approx(retained),
		"resize cancels a held gesture while preserving the chosen physical heading")
	var panel: Control = game.hud._power.get_parent().get_parent()
	var screen := screen_for_table(Vector2(1.1, 0.55))
	require(not panel.get_global_rect().has_point(screen), "resize reframes the table clear of the HUD")
	await mouse_button(screen, false)
	viewport.size = Vector2i(1600, 900)
	for frame in range(3): await process_frame


func settle_shot() -> void:
	for frame in range(2400):
		if not game._shot_in_motion:
			break
		game._process(1.0 / 60.0)


func screen_for_table(point: Vector2) -> Vector2:
	return game.table_view.camera().unproject_position(Vector3(point.x, BallState.RADIUS, point.y))


func mouse_button(point: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	viewport.push_input(event, true)
	await process_frame


func mouse_motion(point: Vector2, buttons: int = 0) -> void:
	var event := InputEventMouseMotion.new()
	event.position = point
	event.button_mask = buttons
	viewport.push_input(event, true)
	await process_frame


func key(code: Key, shift: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	event.shift_pressed = shift
	viewport.push_input(event, true)
	await process_frame
	event = InputEventKey.new()
	event.keycode = code
	event.pressed = false
	event.shift_pressed = shift
	viewport.push_input(event, true)
	await process_frame


func cleanup() -> void:
	game.table_view.cancel_stroke()
	if owns_viewport: viewport.queue_free()
	else: game.queue_free()
	game = null
	viewport = null
	await process_frame
	await process_frame
	for path in [session_file, session_file + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
