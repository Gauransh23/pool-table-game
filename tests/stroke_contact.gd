extends SceneTree
var failures: Array[String] = []
var contacts := 0
var checks := 0
var game: GameController
var session_file := "/tmp/longrail-contact-%d.json" % Time.get_ticks_usec()
func check(value: bool, description: String) -> void:
	checks += 1
	print("%s: %s" % ["PASS" if value else "FAIL", description])
	if not value: failures.append(description)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	game.session_path = session_file
	root.add_child(game)
	game.set_process(false)
	game.hud.hide_menu()
	game._new_rack(false)
	await game.table_view._camera_tween.finished
	if not game.table_view.has_signal("stroke_contact"):
		check(false, "presentation exposes the actual cue contact event")
		await finish()
		return
	game.table_view.connect("stroke_contact", func():
		contacts += 1
		check(game.table_view._cue_root.visible, "cue remains visible through the contact event")
		var cue := game._cue_ball()
		var tip: Vector3 = game.table_view._cue_tip.to_global(Vector3(0, .004, 0))
		var cue_center := Vector3(cue.position.x, cue.height, cue.position.y)
		check(absf(tip.distance_to(cue_center) - BallState.RADIUS) < .0001,
			"visible tip touches ball surface at contact event")
		check(game._shot_in_motion and cue.velocity.length() > 0.0,
			"physics starts at the same cue contact event")
	)
	game._on_shoot_requested(0.0, Vector2.ZERO)
	await create_timer(.25).timeout
	check(not game._shot_in_motion and game._strokes == 0 and contacts == 0, "zero power does not animate, fire or count")
	var invalid_requests := [
		{"power": -0.1, "spin": Vector2.ZERO, "label": "negative power"},
		{"power": NAN, "spin": Vector2.ZERO, "label": "NaN power"},
		{"power": INF, "spin": Vector2.ZERO, "label": "infinite power"},
		{"power": 0.5, "spin": Vector2(NAN, 0.0), "label": "NaN tip offset"},
		{"power": 0.5, "spin": Vector2(INF, 0.0), "label": "infinite tip offset"},
		{"power": 0.5, "spin": Vector2(CueStrikeModel.MAX_TIP_OFFSET + 0.01, 0.0), "label": "tip offset beyond miscue limit"},
	]
	for request in invalid_requests:
		game._on_shoot_requested(request.power, request.spin)
		check(not game._stroke_pending and not game._shot_in_motion and game._strokes == 0 and contacts == 0,
			"%s is rejected before animation, contact or stroke count" % request.label)
	game._new_rack(false)
	game.aim_direction = Vector2.RIGHT
	var original_spin := Vector2(.2, .2)
	game._on_shoot_requested(.4, original_spin)
	check(game._stroke_pending and not game._shot_in_motion, "backswing precedes ball movement")
	game.power = 1.0
	game.spin = Vector2(-.4, 0)
	# UI updates during a pending stroke cannot change its committed inputs.
	await create_timer(.35).timeout
	var expected := BallState.new()
	CueStrikeModel.new().apply(expected, Vector2.RIGHT, load("res://scripts/sim/stroke_power.gd").cue_speed(.4), original_spin, 0, game.physics_config)
	check(game._cue_ball().velocity.is_equal_approx(expected.velocity) and game._cue_ball().angular_velocity.is_equal_approx(expected.angular_velocity), "pending stroke uses captured power and tip position")
	check(contacts == 1 and game._strokes == 1, "one request produces exactly one contact and stroke")
	game._new_rack(false)
	game._on_shoot_requested(.5, Vector2.ZERO)
	game._open_menu()
	game.hud.hide_menu()
	await create_timer(.35).timeout
	check(not game._shot_in_motion and not game._stroke_pending and game._strokes == 0 and contacts == 1, "menu cancels pending contact without ghost shot on resume")
	game._on_shoot_requested(.5, Vector2.ZERO)
	game._new_rack(false)
	await create_timer(.35).timeout
	check(not game._shot_in_motion and game._strokes == 0 and contacts == 1, "new rack cancels pending contact")
	game._on_shoot_requested(.5, Vector2.ZERO)
	check(game._stroke_pending, "window-focus probe begins during pending contact animation")
	root.propagate_notification(Window.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	check(not game._stroke_pending and not game._shot_in_motion, "window focus loss cancels the pending stroke immediately")
	await create_timer(.35).timeout
	check(not game._shot_in_motion and not game._stroke_pending and game._strokes == 0 and contacts == 1,
		"resuming after window focus loss produces no phantom contact")
	game._on_shoot_requested(.5, Vector2.ZERO)
	check(game._stroke_pending, "camera probe begins during pending contact animation")
	var camera_before := game._overhead
	game._toggle_view()
	check(game._overhead == camera_before and game._stroke_pending, "camera switch is ignored without disturbing a pending stroke")
	await create_timer(.35).timeout
	check(game._shot_in_motion and game._strokes == 1 and contacts == 2, "ignored camera switch leaves pending stroke stable through contact")
	await finish()
func finish() -> void:
	game.queue_free()
	await process_frame
	for path in [session_file, session_file + ".tmp"]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	print("STROKE CONTACT: %d checks, %d failures" % [checks, failures.size()])
	quit(1 if not failures.is_empty() else 0)
