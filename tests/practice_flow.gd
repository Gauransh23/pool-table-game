extends SceneTree
var checks := 0
var failures := 0
func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		printerr("FAIL: "+description); failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	scene.session_path="/tmp/longrail-flow-%d.json" % Time.get_ticks_usec()
	root.add_child(scene)
	scene.set_process(false); scene.hud.hide_menu()
	await scene.table_view._camera_tween.finished
	scene._new_rack()
	var original: Array=[]
	for ball in scene.balls: original.append(ball.canonical_state())
	scene._on_shoot_requested(.65,Vector2.ZERO)
	await create_timer(.20).timeout
	check(scene._shot_in_motion,"shot starts after cue animation")
	for frame in range(2400):
		scene._process(1.0/60.0)
		if not scene._shot_in_motion: break
	check(not scene._shot_in_motion,"break settles without forced timeout")
	check(scene._strokes==1,"stroke counted once")
	for ball in scene.balls:
		check(is_finite(ball.position.x) and is_finite(ball.position.y),"finite break state")
	scene._undo_shot()
	for index in range(16): check(scene.balls[index].canonical_state()==original[index],"undo restores exact pre-shot state")
	check(scene._strokes==0,"undo restores stroke count")
	scene._placing=true
	var cue=scene._cue_ball()
	var before=cue.position
	scene._place_cue(scene.balls[1].position)
	check(scene._placing and cue.position==before,"placement rejects overlap")
	scene._place_cue(Vector2(-.4,.2))
	check(not scene._placing and cue.position==Vector2(-.4,.2),"clear cue placement works")
	scene._save_session(); cue.position=Vector2.ZERO
	check(scene._load_session() and scene._cue_ball().position==Vector2(-.4,.2),"session restores saved state")
	var bad = JSON.parse_string(FileAccess.get_file_as_string(scene.session_path))
	bad.balls[1][1] = 0
	var bad_file := FileAccess.open(scene.session_path,FileAccess.WRITE)
	bad_file.store_string(JSON.stringify(bad)); bad_file.close()
	check(not scene._load_session(),"corrupted duplicate ball numbers are rejected")
	DirAccess.remove_absolute(scene.session_path)
	scene._new_rack(false)
	scene._on_shoot_requested(.5,Vector2.ZERO)
	scene._new_rack(false)
	await create_timer(.13).timeout
	check(not scene._shot_in_motion and scene._strokes == 0,"re-rack cancels pending stroke safely")
	var image:=Image.new()
	image.load_svg_from_string(FileAccess.get_file_as_string("res://assets/icon.svg"))
	check(not image.is_empty(), "project icon loads")
	scene.queue_free()
	await process_frame
	call_deferred("finish")

func finish() -> void:
	print("PRACTICE FLOW: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
