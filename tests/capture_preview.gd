extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var arguments := OS.get_cmdline_user_args()
	root.size = Vector2i(1100,700) if "--small" in arguments else Vector2i(1600,900)
	var game = load("res://scenes/main.tscn").instantiate()
	var session := "user://capture-%d.json" % Time.get_ticks_usec()
	game.session_path = session
	root.add_child(game)
	game.hud.hide_menu()
	game._new_rack(false)
	game.table_view.set_overhead(not "--lounge" in arguments)
	await game.table_view._camera_tween.finished
	if "--spread" in arguments:
		for index in range(game.balls.size()):
			game.balls[index].position = Vector2(-.9 + .6 * (index % 4), -.40 + .265 * (index / 4))
		game.table_view.sync_balls(game.balls)
		game._last_aim_state.clear()
		game._refresh_aim()
	if "--break" in arguments:
		game._on_shoot_requested(.75, Vector2.ZERO)
		await create_timer(4.0).timeout
	for frame in range(3): await process_frame
	await RenderingServer.frame_post_draw
	var path := "user://longrail-%d.png" % Time.get_ticks_usec()
	for argument in arguments:
		if argument.begins_with("--output="): path = argument.trim_prefix("--output=")
	var capture_image := root.get_texture().get_image()
	var error := capture_image.save_png(path)
	var metadata := {"window_size":str(root.size),"design_size":str(root.content_scale_size),"viewport_size":str(root.get_visible_rect().size),"image_size":str(capture_image.get_size()),"meaning":"The configured canvas preserves design aspect; the render image excludes window letterboxing."}
	var metadata_file := FileAccess.open(path+".json",FileAccess.WRITE)
	if metadata_file != null:
		metadata_file.store_string(JSON.stringify(metadata,"\t"))
		metadata_file.close()
	print(JSON.stringify(metadata))
	if error == OK: print("CAPTURE: %s" % ProjectSettings.globalize_path(path))
	else: printerr("Capture failed (%s): %s" % [error, path])
	game.queue_free()
	await process_frame
	for candidate in [session, session + ".tmp"]:
		if FileAccess.file_exists(candidate): DirAccess.remove_absolute(candidate)
	quit(0 if error == OK else 1)
