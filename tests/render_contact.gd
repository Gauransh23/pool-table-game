extends SceneTree
var contact := false
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1600,900)
	var game = load("res://scenes/main.tscn").instantiate()
	game.session_path = "user://contact-render-%d.json" % Time.get_ticks_usec()
	root.add_child(game)
	game.hud.hide_menu()
	game._new_rack(false)
	await game.table_view._camera_tween.finished
	game.table_view.stroke_contact.connect(func(): contact = true)
	var visual: Node3D = game.table_view._ball_nodes[0]
	var initial: Vector3 = visual.position
	var contact_frame := -1
	var motion_frame := -1
	var contact_visible := false
	var capture_saved := false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://captures"))
	game._on_shoot_requested(.12,Vector2(.1,.2))
	for frame in range(90):
		await RenderingServer.frame_post_draw
		if contact and contact_frame < 0:
			contact_frame = frame
			contact_visible = game.table_view._cue_root.visible
			var path := "res://captures/contact-frame.png"
			var error := root.get_texture().get_image().save_png(path)
			capture_saved = error == OK
			if error != OK: printerr("Could not write contact capture: %d" % error)
		if contact and visual.position.distance_to(initial) > 0.000001 and motion_frame < 0: motion_frame = frame
		if motion_frame >= 0 and frame > motion_frame + 3: break
	var result := {"renderer":RenderingServer.get_current_rendering_method(),"contact_frame":contact_frame,"first_motion_frame":motion_frame,"gap_frames":motion_frame-contact_frame,"cue_visible_at_rendered_contact":contact_visible,"meaning":"Rendered frames; does not measure display scan-out, native input or audio device latency."}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/quality-roadmap/reports"))
	var file := FileAccess.open("res://docs/quality-roadmap/reports/render-contact.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(result,"\t"));file.close()
	print(JSON.stringify(result))
	var passed := capture_saved and contact_visible and contact_frame >= 0 and motion_frame >= contact_frame and motion_frame-contact_frame <= 1
	game.queue_free()
	await process_frame
	quit(0 if passed else 1)
