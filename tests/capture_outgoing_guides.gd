extends SceneTree

# Deterministic isolated cut fixture for lead visual review (no save writes).
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var output := "/tmp/pool-outgoing-guides.png"
	var small := false
	var lounge := false
	for argument in OS.get_cmdline_user_args():
		if argument == "--small": small = true
		elif argument == "--lounge": lounge = true
		elif argument.begins_with("--output="): output = argument.trim_prefix("--output=")
	if small: root.size = Vector2i(1100, 700)
	var game = load("res://scenes/main.tscn").instantiate()
	game.session_path = "/tmp/pool-outgoing-capture-%s.json" % Time.get_ticks_usec()
	root.add_child(game)
	await process_frame
	if lounge:
		game._overhead = false
		game.table_view.set_overhead(false)
	if game.table_view._camera_tween.is_running(): await game.table_view._camera_tween.finished
	game.hud.hide_menu()
	game._placing = false
	game._strokes = 0
	game._pots = 0
	game._update_score()
	var layout: Array[BallState] = [BallState.new(0, 0, Vector2(-0.35, 0.12)), BallState.new(1, 1, Vector2(0.0, 0.155))]
	game.balls = layout
	# Hide unused rack visuals retained by sync_balls.
	for key in game.table_view._ball_nodes:
		game.table_view._ball_nodes[key].hide()
	game.table_view.sync_balls(game.balls)
	game.aim_direction = Vector2.RIGHT
	game.power = 0.42
	game.spin = Vector2(0.0, -0.25)
	game.hud._spin.spin = game.spin
	game.hud.selected_spin = game.spin
	game._last_aim_state.clear()
	for unused in range(240):
		await process_frame
		if game._guide_applied: break
	if not game._guide_applied or game._guide_prediction.result.get("status", "") != "predicted":
		printerr("Capture failed: outgoing prediction did not complete")
		quit(1)
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(output)
	if error != OK:
		printerr("Capture PNG failed: " + error_string(error))
		quit(1)
		return
	print("OUTGOING CAPTURE: " + output)
	quit()
