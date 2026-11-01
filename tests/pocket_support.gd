extends SceneTree
var checks := 0
var failures: Array[String] = []
func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures.append(description)
		printerr("FAIL: " + description)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var table := TableSpec.new()
	var config := PhysicsConfig.new()
	for pocket in table.pocket_definitions():
		var id: int = pocket.id
		var outward: Vector2 = pocket.outward
		var mouth: Vector2 = pocket.mouth_center
		var fall_center: Vector2 = (pocket.fall_a + pocket.fall_b) * .5
		var supported := BallState.new(id,id,mouth - outward * .02)
		var simulator := PhysicsStepper.new()
		simulator.step_fixed([supported],config.fixed_step,config,table)
		check(supported.phase == BallState.Phase.IN_PLAY and supported.vertical_velocity == 0, "pocket %d: supported ball cannot be pulled into pocket" % id)
		var shelf := BallState.new(id,id,(mouth+fall_center)*.5)
		simulator.step_fixed([shelf],config.fixed_step,config,table)
		check(shelf.phase == BallState.Phase.IN_PLAY, "pocket %d: finite shelf remains supported" % id)
		var falling := BallState.new(id,id,fall_center + outward * (BallState.RADIUS + .002))
		simulator = PhysicsStepper.new()
		simulator.step_fixed([falling],config.fixed_step,config,table)
		check(falling.phase == BallState.Phase.FALLING and falling.vertical_velocity == 0, "pocket %d: support loss begins fall without downward kick" % id)
		check(simulator.drain_events().is_empty(), "pocket %d: mouth entry does not score" % id)
		var old_height := falling.height
		simulator.step_fixed([falling],config.fixed_step,config,table)
		check(falling.height < old_height and is_equal_approx(falling.vertical_velocity,-config.gravity*config.fixed_step), "pocket %d: gravity drives descent" % id)
		var captures := 0
		for tick in range(200):
			simulator.step_fixed([falling],config.fixed_step,config,table)
			for event in simulator.drain_events():
				if event.kind == "pocket":
					captures += 1
					check(event.pocket_id == id and falling.height <= -BallState.RADIUS, "pocket %d: scoring follows passage below slate" % id)
		check(falling.phase == BallState.Phase.POCKETED and captures == 1, "pocket %d: one irreversible capture event" % id)
		var returning := BallState.new(id,id,mouth-outward*.015)
		returning.phase = BallState.Phase.FALLING
		returning.pocket_id = id
		returning.height = BallState.RADIUS-.0001
		PhysicsStepper.new().step_fixed([returning],config.fixed_step,config,table)
		check(returning.phase == BallState.Phase.IN_PLAY and returning.pocket_id == -1, "pocket %d: supported re-entry can recover before capture" % id)
	var edge := BallState.new(0,1,Vector2(0,table.half_size.y-BallState.RADIUS+.001))
	PhysicsStepper.new().step_fixed([edge],config.fixed_step,config,table)
	check(edge.phase == BallState.Phase.IN_PLAY, "original premature side-pocket capture remains fixed")
	print("POCKET SUPPORT: %d checks, %d failures" % [checks,failures.size()])
	quit(1 if not failures.is_empty() else 0)
