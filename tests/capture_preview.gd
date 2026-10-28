extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size=Vector2i(1600,900)
	var game=load("res://scenes/main.tscn").instantiate()
	game.session_path="/tmp/longrail-preview-session.json"
	root.add_child(game); game.hud.hide_menu(); game._new_rack(false)
	if "--overhead" in OS.get_cmdline_user_args(): game._toggle_view()
	if "--break" in OS.get_cmdline_user_args():
		game._on_shoot_requested(.75,Vector2.ZERO)
		await create_timer(4.0).timeout
	for frame in range(80): await process_frame
	await RenderingServer.frame_post_draw
	var path: String="/tmp/longrail-overhead.png" if "--overhead" in OS.get_cmdline_user_args() else "/tmp/longrail-preview.png"
	root.get_texture().get_image().save_png(path)
	game.queue_free(); await process_frame
	call_deferred("quit")
