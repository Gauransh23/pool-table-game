extends SceneTree

const BallState = preload("res://scripts/sim/ball_state.gd")
const PhysicsConfig = preload("res://scripts/sim/physics_config.gd")
const PhysicsStepper = preload("res://scripts/sim/physics_stepper.gd")
const TableSpec = preload("res://scripts/sim/table_spec.gd")
const CueStrikeModel = preload("res://scripts/sim/cue_strike_model.gd")
const StrokePower = preload("res://scripts/sim/stroke_power.gd")
const GameHUD = preload("res://scripts/ui/game_hud.gd")

const REPORT_DIR := "res://docs/quality-roadmap/reports"
const CSV_PATH := REPORT_DIR + "/stroke-power.csv"

var failures := 0
var measurements: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_mapping_edges()
	await _test_hud_control()
	_run_travel_sweep()
	_write_csv()
	if failures == 0:
		print("PASS: stroke power mapping, UI, and %d simulated settings" % measurements.size())
		quit(0)
	else:
		printerr("FAIL: %d stroke power assertions" % failures)
		quit(1)


func _check(condition: bool, description: String) -> void:
	print("%s: %s" % ["PASS" if condition else "FAIL", description])
	if not condition:
		failures += 1


func _test_mapping_edges() -> void:
	_check(StrokePower.cue_speed(0.0) == 0.0, "zero power maps to no cue motion")
	_check(StrokePower.cue_speed(-0.25) == 0.0, "negative power maps to no shot")
	_check(StrokePower.cue_speed(NAN) == 0.0, "NaN power maps to no shot")
	_check(StrokePower.cue_speed(INF) == 0.0, "positive infinity maps to no shot")
	_check(StrokePower.cue_speed(-INF) == 0.0, "negative infinity maps to no shot")
	_check(is_equal_approx(StrokePower.cue_speed(1.0), 8.0), "full power preserves the old 8 m/s maximum")
	_check(is_equal_approx(StrokePower.cue_speed(2.0), 8.0), "power above one clamps to full cue speed")
	_check(StrokePower.cue_speed(0.005) > 0.0, "small positive UI power remains a shot")


func _test_hud_control() -> void:
	var hud: GameHUD = GameHUD.new()
	root.add_child(hud)
	await process_frame
	_check(hud._power.min_value == 0.0 and hud._power.max_value == 1.0 and is_equal_approx(hud._power.step, 0.005),
		"power slider spans 0..1 in 0.005 steps")
	var shots: Array[int] = []
	hud.shoot_requested.connect(func(_power: float, _spin: Vector2): shots.append(1))
	hud._power.value = 0.005
	_check(hud._readout.text == "0.5%", "half-percent setting is shown exactly")
	hud._power.value = 0.0
	_check(hud._readout.text == "0.0%" and hud._shoot.disabled, "zero power reads zero and disables shooting")
	hud._request_shot()
	_check(shots.is_empty(), "zero power cannot emit a shot even through the shot callback")
	hud._power.value = 0.01
	_check(hud._readout.text == "1.0%" and not hud._shoot.disabled, "one-percent setting reads exactly and permits shooting")
	hud._shoot.pressed.emit()
	_check(shots.size() == 1, "nonzero power emits a shot")
	hud.queue_free()
	await process_frame


func _run_travel_sweep() -> void:
	var power_ticks: Array[int] = []
	for tick in range(10, 201, 10):
		power_ticks.append(tick)
	for tick in range(1, 21):
		if not power_ticks.has(tick):
			power_ticks.append(tick)
	power_ticks.sort()

	var zero := _measure(0.0)
	measurements.append(zero)
	for tick in power_ticks:
		measurements.append(_measure(float(tick) * 0.005))

	_check(is_zero_approx(float(measurements[0]["distance_m"])), "zero power has zero stopping distance")
	for index in range(1, measurements.size()):
		var previous: float = measurements[index - 1]["distance_m"]
		var current: float = measurements[index]["distance_m"]
		var power: float = measurements[index]["power"]
		_check(current > previous, "stopping distance increases at %s%%" % String.num(power * 100.0, 1))

	var minimum_step: Dictionary = measurements[1]
	_check(minimum_step["distance_m"] >= 0.02 and minimum_step["distance_m"] <= 0.10,
		"minimum 0.5% UI step travels " + String.num(float(minimum_step["distance_m"]), 4) + " m (target 0.02..0.10 m)")
	for index in range(1, 21):
		var previous: float = measurements[index - 1]["distance_m"]
		var current: float = measurements[index]["distance_m"]
		_check(current > previous, "no zero-response UI step at " + String.num(float(index) * 0.5, 1) + "%")


func _measure(power: float) -> Dictionary:
	var config := PhysicsConfig.new()
	var table := TableSpec.new()
	table.half_size = Vector2(10000.0, 10000.0)
	var ball := BallState.new()
	var cue_speed := StrokePower.cue_speed(power)
	if cue_speed > 0.0:
		CueStrikeModel.new().apply(ball, Vector2.RIGHT, cue_speed, Vector2.ZERO, 0.0, config)
	var initial_ball_speed := ball.velocity.length()
	var stepper := PhysicsStepper.new()
	var ticks := 0
	while not stepper.are_balls_settled([ball], config) and ticks < 200000:
		stepper.step_fixed([ball], config.fixed_step, config, table)
		ticks += 1
	var settled := stepper.are_balls_settled([ball], config)
	_check(settled, "simulation settles at %.3f%% within tick budget" % (power * 100.0))
	return {
		"power": power,
		"cue_speed_mps": cue_speed,
		"initial_ball_speed_mps": initial_ball_speed,
		"distance_m": ball.position.length(),
		"settle_time_s": float(ticks) * config.fixed_step,
		"ticks": ticks,
		"settled": settled,
	}


func _write_csv() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REPORT_DIR))
	var file := FileAccess.open(CSV_PATH, FileAccess.WRITE)
	if file == null:
		_check(false, "measurement CSV can be written")
		return
	file.store_line("power_percent,cue_speed_mps,initial_ball_speed_mps,stopping_distance_m,settle_time_s,ticks,settled")
	for row in measurements:
		file.store_line("%s,%s,%s,%s,%s,%d,%s" % [
			String.num(float(row["power"]) * 100.0, 1),
			String.num(float(row["cue_speed_mps"]), 6),
			String.num(float(row["initial_ball_speed_mps"]), 6),
			String.num(float(row["distance_m"]), 9),
			String.num(float(row["settle_time_s"]), 6),
			int(row["ticks"]),
			str(row["settled"]),
		])
	_check(true, "wrote measured travel and settle-time CSV at %s" % CSV_PATH)
