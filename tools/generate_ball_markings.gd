extends SceneTree
# Renders Godot's bundled default font into original ball-number artwork.
# Run with a graphical renderer: bash tools/godot.sh --path . --script tools/generate_ball_markings.gd
class NumberCanvas extends Node2D:
	var number := 1
	func _draw() -> void:
		draw_rect(Rect2(0,0,256,256), Color("f7f1df"))
		var font := ThemeDB.fallback_font
		var text := str(number)
		var font_size := 132 if number < 10 else 112
		var extent := font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size)
		var baseline := 128.0 + (font.get_ascent(font_size) - font.get_descent(font_size)) * .5
		draw_string(font,Vector2((256-extent.x)*.5,baseline),text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color("17201c"))
		if number in [6,9]: draw_line(Vector2(101,205),Vector2(155,205),Color("17201c"),5,true)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(256,256)
	root.content_scale_size = Vector2i(256,256)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/markings"))
	var canvas := NumberCanvas.new()
	root.add_child(canvas)
	for number in range(1,16):
		canvas.number = number
		canvas.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var error := root.get_texture().get_image().save_png("res://assets/markings/ball-%02d.png" % number)
		if error != OK:
			printerr("Could not write ball marking %d: %d" % [number,error])
			quit(1)
			return
	canvas.queue_free()
	print("Generated 15 ball markings using Godot's bundled font.")
	quit()
