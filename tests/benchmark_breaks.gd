extends SceneTree

const BallState = preload("res://scripts/sim/ball_state.gd")
const PhysicsConfig = preload("res://scripts/sim/physics_config.gd")
const PhysicsStepper = preload("res://scripts/sim/physics_stepper.gd")
const TableSpec = preload("res://scripts/sim/table_spec.gd")
const CueStrikeModel = preload("res://scripts/sim/cue_strike_model.gd")
const RackBuilder = preload("res://scripts/game/rack_builder.gd")

const TRIALS := 3
const SIMULATED_SECONDS := 4.0
const RENDER_HZ := 60.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for trial in range(TRIALS):
		var table := TableSpec.new()
		var config := PhysicsConfig.new()
		var balls: Array[BallState] = RackBuilder.create_eight_ball_rack(table)
		var cue_ball: BallState = balls[0]
		CueStrikeModel.new().apply(cue_ball, Vector2.RIGHT, 7.5, Vector2(0.0, 0.0), 0.0, config)
		var stepper := PhysicsStepper.new()
		var frame_count := int(SIMULATED_SECONDS * RENDER_HZ)
		var start_usec := Time.get_ticks_usec()
		for frame in range(frame_count):
			stepper.advance(balls, 1.0 / RENDER_HZ, config, table)
		var elapsed_usec := Time.get_ticks_usec() - start_usec
		var expected_ticks := int(SIMULATED_SECONDS / config.fixed_step)
		print("trial=%d simulated_seconds=%.2f wall_ms=%.3f expected_fixed_ticks=%d reported_tick_count=%d" % [
			trial + 1,
			SIMULATED_SECONDS,
			float(elapsed_usec) / 1000.0,
			expected_ticks,
			stepper.tick_count,
		])
	quit(0)
