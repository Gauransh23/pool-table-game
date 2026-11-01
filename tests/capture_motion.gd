extends SceneTree
# Source-rendered visual evidence; movie-maker fixed FPS is not a frame-pacing benchmark.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(1280,720)
	var game = load("res://scenes/main.tscn").instantiate()
	game.session_path = "user://motion-capture-%d.json" % Time.get_ticks_usec()
	root.add_child(game)
	game.hud.hide_menu()
	await game.table_view._camera_tween.finished
	var shots := [{"power":.005,"tip":Vector2.ZERO,"seconds":4.0}, {"power":.6,"tip":Vector2(0,-.35),"seconds":10.0}, {"power":.9,"tip":Vector2(.25,.15),"seconds":16.0}]
	for shot in shots:
		game._new_rack(false)
		game.hud._power.value = shot.power
		game.hud._spin.spin = shot.tip
		game.hud._spin.queue_redraw()
		game.hud.selected_spin = shot.tip
		game._on_shoot_requested(shot.power,shot.tip)
		await create_timer(shot.seconds).timeout
	game.queue_free()
	await process_frame
	quit()
