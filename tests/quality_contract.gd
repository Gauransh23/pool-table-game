extends SceneTree
# Future acceptance contract, intentionally red on the 0.2.0 baseline.
# Keep separate from existing regression tests until the corresponding work lands.
var failed: Array[String] = []
func require_quality(id: String, condition: bool, measurement: String) -> void:
	print("%s %s: %s" % ["PASS" if condition else "FAIL", id, measurement])
	if not condition: failed.append(id)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var table := TableSpec.new()
	var config := PhysicsConfig.new()
	var ball := BallState.new(0,1,Vector2(0,table.half_size.y-BallState.RADIUS+.001))
	PhysicsStepper.new().step_fixed([ball],config.fixed_step,config,table)
	require_quality("PHY-SHELF-01",ball.phase==BallState.Phase.IN_PLAY,
		"stationary center is %.5fm inside the mouth plane; phase=%d (must stay supported)" % [table.half_size.y-ball.position.y,ball.phase])
	var wide := TableSpec.new(); wide.half_size=Vector2(10,10)
	var soft := BallState.new()
	CueStrikeModel.new().apply(soft,Vector2.RIGHT,.25+.01*7.75,Vector2.ZERO,0,config)
	var sim := PhysicsStepper.new()
	for tick in range(4800): sim.step_fixed([soft],config.fixed_step,config,wide)
	require_quality("CTL-SOFT-01",soft.position.length()<=.10,
		"minimum UI center stroke rolls %.4fm; proposed delicate-touch target <=0.10m" % soft.position.length())
	var game=load("res://scenes/main.tscn").instantiate()
	game.session_path="/tmp/longrail-quality-contract.json"
	root.add_child(game);game.set_process(false);game.hud.hide_menu();game._new_rack(false)
	game.aim_direction=Vector2.RIGHT
	var motion:=InputEventMouseMotion.new();motion.position=Vector2(100,100);motion.button_mask=0
	game._unhandled_input(motion)
	require_quality("CTL-LOCK-01",game.aim_direction.is_equal_approx(Vector2.RIGHT),
		"unpressed pointer travel changed aim to %s; target is explicit aiming gesture" % game.aim_direction)
	game._save_session()
	var data=JSON.parse_string(FileAccess.get_file_as_string(game.session_path))
	data.balls[0][5]=2.0
	var file:=FileAccess.open(game.session_path,FileAccess.WRITE);file.store_string(JSON.stringify(data));file.close()
	var loaded:bool=game._load_session()
	require_quality("LIFE-SAVE-01",not loaded or game._shot_in_motion,
		"moving IN_PLAY saved state accepted=%s; simulation running=%s" % [loaded,game._shot_in_motion])
	DirAccess.remove_absolute(game.session_path)
	game.queue_free(); await process_frame
	print("QUALITY CONTRACT: %d unmet targets" % failed.size())
	quit(1 if not failed.is_empty() else 0)
