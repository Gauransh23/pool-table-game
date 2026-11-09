extends SceneTree
var rows: Array = []
func _initialize(): call_deferred("run")
func run():
	var started := Time.get_ticks_usec()
	for tick in range(201): measure(tick,Vector2.ZERO)
	for tick in [1,10,20,40,80,120,160,200]:
		for tip in [Vector2(0,.45),Vector2(0,-.45),Vector2(.45,0),Vector2(-.45,0),Vector2(.318198,.318198),Vector2(-.318198,-.318198)]: measure(tick,tip)
	var f := FileAccess.open("/tmp/pool-task-c-results.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"wall_ms":(Time.get_ticks_usec()-started)/1000.0,"rows":rows}))
	f.close()
	print("TASK_C rows=",rows.size()," wall_ms=",(Time.get_ticks_usec()-started)/1000.0)
	quit()
func measure(tick:int, tip:Vector2):
	var config := PhysicsConfig.new()
	var table := TableSpec.new()
	table.half_size = Vector2(10000,10000)
	var ball := BallState.new()
	var cue := StrokePower.cue_speed(tick*.005)
	var strike := CueStrikeModel.new()
	strike.apply(ball,Vector2.RIGHT,cue,tip,0.0,config)
	var launch := ball.velocity.length()
	var launch_spin := [ball.angular_velocity.x,ball.angular_velocity.y,ball.angular_velocity.z]
	var stepper := PhysicsStepper.new()
	var ticks := 0
	var roll_tick := -1
	var roll_position := Vector2.ZERO
	while not stepper.are_balls_settled([ball],config) and ticks<40000:
		stepper.step_fixed([ball],config.fixed_step,config,table)
		ticks += 1
		if roll_tick < 0 and stepper.contact_slip(ball).length() <= .0005:
			roll_tick = ticks
			roll_position = ball.position
	rows.append({"tick":tick,"tip":[tip.x,tip.y],"cue":cue,"launch":launch,"spin":launch_spin,"distance":ball.position.length(),"endpoint":[ball.position.x,ball.position.y],"ticks":ticks,"roll_tick":roll_tick,"roll_distance":roll_position.length(),"settled":stepper.are_balls_settled([ball],config)})
