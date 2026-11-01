extends SceneTree

# Measurement harness for the current playable GDScript solver. Results are
# comparative evidence, not a claim that this solver is physical ground truth.
var output_dir := "res://docs/quality-roadmap/reports/physics-precision"
const RESOLUTIONS := [240, 480, 960, 1920]
const BALL_DIAMETER := BallState.RADIUS * 2.0

var records: Array[Dictionary] = []
var failures: Array[String] = []
var table := TableSpec.new()
var stepper_script: Script = preload("res://scripts/sim/physics_stepper.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output-dir="): output_dir = argument.trim_prefix("--output-dir=")
		if argument.begins_with("--stepper="): stepper_script = load(argument.trim_prefix("--stepper="))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	for resolution in RESOLUTIONS:
		for phase in [0.0, 0.25, 0.5, 0.75]:
			records.append(run_case("phase_head_on", resolution, phase))
		for name in ["head_on", "cut_positive", "cut_negative", "pure_rolling", "rail_spin_positive", "rail_spin_negative", "analytic_head_on", "analytic_cut"]:
			records.append(run_case(name, resolution, -1.0))
	for pocket_id in range(6):
		records.append(run_support_probe(pocket_id))

	var output_json := {"solver": stepper_script.resource_path, "selected_stepper_sha256": source_sha256(stepper_script.resource_path), "resolutions_hz": RESOLUTIONS,
		"table": {"half_size_m": [table.half_size.x, table.half_size.y], "ball_radius_m": BallState.RADIUS},
		"source_sha256": {"physics_stepper.gd": source_sha256("res://scripts/sim/physics_stepper.gd"),
			"table_spec.gd": source_sha256("res://scripts/sim/table_spec.gd"), "physics_config.gd": source_sha256("res://scripts/sim/physics_config.gd"),
			"physics_precision.gd": source_sha256("res://tests/physics_precision.gd")},
		"godot_version": Engine.get_version_info().string,
		"records": records, "evaluation": evaluate_convergence(), "analytic_checks": evaluate_analytic_checks(),
		"mirror_checks": evaluate_mirrors()}
	write_json("runs.json", output_json)
	write_csv()
	print("PHYSICS PRECISION: %d runs, %d pocket probes, %d threshold misses" % [records.size() - 6, 6, failures.size()])
	for failure in failures:
		printerr("MEASURED LIMIT: " + failure)
	quit(1 if "--enforce" in OS.get_cmdline_user_args() and not failures.is_empty() else 0)

func run_case(name: String, resolution: int, phase: float) -> Dictionary:
	var config := PhysicsConfig.new()
	config.fixed_step = 1.0 / float(resolution)
	var analytic_case := name.begins_with("analytic_") or name == "phase_head_on"
	if analytic_case:
		config.ball_restitution = 1.0
		config.ball_friction = 0.0
		config.sliding_friction = 0.0
		config.rolling_resistance = 0.0
		config.spinning_friction = 0.0
	if name == "analytic_head_on" or name == "analytic_cut" or name == "phase_head_on":
		config.cushion_friction = 0.0
	var balls: Array[BallState] = make_case(name, resolution, phase)
	var initial := snapshot(balls)
	var stepper = stepper_script.new()
	var events: Array[Dictionary] = []
	var duration := 0.45
	if name == "pure_rolling": duration = 1.5
	if name.begins_with("rail_spin"): duration = 0.16
	var tick_limit := ceili(duration / config.fixed_step)
	for tick in range(tick_limit):
		stepper.step_fixed(balls, config.fixed_step, config, table)
		for event in stepper.drain_events(): events.append(event)
	var terminal := snapshot(balls)
	var event_counts := {"ball_contact": 0, "rail": 0, "pocket": 0, "off_table": 0}
	var first_contact_tick := -1
	var first_rail_tick := -1
	for event in events:
		var kind := str(event.get("kind", "unknown"))
		if not event_counts.has(kind): event_counts[kind] = 0
		event_counts[kind] += 1
		if kind == "ball_contact" and first_contact_tick < 0: first_contact_tick = int(event.get("tick", -1))
		if kind == "rail" and first_rail_tick < 0: first_rail_tick = int(event.get("tick", -1))
	return {"case": name, "resolution_hz": resolution, "contact_phase_fraction": phase,
		"duration_s": tick_limit * config.fixed_step, "initial_parameters": config_parameters(config),
		"initial_balls": initial, "terminal_balls": terminal, "events": events,
		"event_metrics": {"counts": event_counts, "first_contact_tick": first_contact_tick,
			"first_contact_time_s": first_contact_tick * config.fixed_step if first_contact_tick >= 0 else -1.0,
			"first_rail_tick": first_rail_tick,
			"first_rail_time_s": first_rail_tick * config.fixed_step if first_rail_tick >= 0 else -1.0},
		"initial_energy_j": total_energy(initial, config), "terminal_energy_j": total_energy(terminal, config),
		"initial_energy_components_j": energy_breakdown(initial, config), "terminal_energy_components_j": energy_breakdown(terminal, config),
		"initial_momentum_kg_m_s": momentum(initial, config), "terminal_momentum_kg_m_s": momentum(terminal, config)}

func make_case(name: String, resolution: int, phase: float) -> Array[BallState]:
	var balls: Array[BallState] = []
	if name == "pure_rolling":
		var rolling := BallState.new(0, 0, Vector2(-0.2, 0.1))
		rolling.velocity = Vector2(0.5, 0.3)
		rolling.angular_velocity = Vector3(rolling.velocity.y / BallState.RADIUS, 0.0, -rolling.velocity.x / BallState.RADIUS)
		balls.append(rolling)
		return balls
	if name.begins_with("rail_spin"):
		var rail_ball := BallState.new(0, 0, Vector2(-0.3, 0.57))
		rail_ball.velocity = Vector2(0.0, 1.2)
		rail_ball.angular_velocity.y = 18.0 if name.ends_with("positive") else -18.0
		balls.append(rail_ball)
		return balls
	var offset := Vector2.ZERO
	var start := Vector2(-0.28, 0.0)
	var speed := 2.0
	if name == "cut_positive" or name == "analytic_cut": offset.y = 0.025
	if name == "cut_negative": offset.y = -0.025
	if name == "phase_head_on":
		# Same initial position at every resolution. `phase` shifts impact by a
		# fraction of the coarsest (240 Hz) step to sample the full phase interval.
		start.x = -BALL_DIAMETER - speed * (0.1 + phase / 240.0)
	if name == "cut_positive" or name == "cut_negative" or name == "analytic_cut":
		start.y = offset.y
	var moving := BallState.new(0, 0, start)
	moving.velocity = Vector2.RIGHT * speed
	var target := BallState.new(1, 1, Vector2.ZERO)
	balls.append(moving); balls.append(target)
	return balls

func run_support_probe(pocket_id: int) -> Dictionary:
	var z_sign := 1.0 if pocket_id in [0, 2, 4] else -1.0
	var x_sign := -1.0 if pocket_id in [0, 1] else 1.0
	var center := Vector2.ZERO
	if pocket_id < 4:
		center = Vector2(x_sign * (table.half_size.x - BallState.RADIUS + 0.001),
			z_sign * (table.half_size.y - BallState.RADIUS + 0.001))
	else:
		center = Vector2(0.0, z_sign * (table.half_size.y - BallState.RADIUS + 0.001))
	var config := PhysicsConfig.new()
	var inner := center
	inner.y = z_sign * (table.half_size.y - BallState.RADIUS - 0.001)
	var samples := [support_sample("inner_side_of_current_threshold", inner, config),
		support_sample("just_beyond_current_threshold", center, config)]
	var trigger_after: Dictionary = samples[1].after
	return {"case": "stationary_support_probe", "pocket_id": pocket_id, "resolution_hz": 0,
		"contact_phase_fraction": -1.0, "duration_s": config.fixed_step, "initial_parameters": config_parameters(config),
		"initial_balls": [samples[1].before], "terminal_balls": [trigger_after], "support_samples": samples, "events": samples[1].events,
		"event_metrics": {"counts": {"ball_contact": 0, "rail": 0, "pocket": 1 if int(trigger_after.phase) == BallState.Phase.FALLING else 0,
			"off_table": 0}, "first_contact_tick": -1, "first_contact_time_s": -1.0,
		"classified_pocket": table.pocket_at(center)}, "initial_energy_j": 0.0, "terminal_energy_j": 0.5 * BallState.MASS * float(trigger_after.vertical_velocity_m_s) * float(trigger_after.vertical_velocity_m_s),
		"initial_momentum_kg_m_s": [0.0, 0.0, 0.0], "terminal_momentum_kg_m_s": [0.0, BallState.MASS * float(trigger_after.vertical_velocity_m_s), 0.0]}

func support_sample(label: String, position: Vector2, config: PhysicsConfig) -> Dictionary:
	var ball := BallState.new(0, 0, position)
	var before := {"position_m": [position.x, position.y], "phase": ball.phase, "pocket_at": table.pocket_at(position),
		"outside_table": table.outside_table(position), "distance_inside_end_plane_m": table.half_size.y - absf(position.y),
		"distance_inside_side_plane_m": table.half_size.x - absf(position.x)}
	var stepper = stepper_script.new()
	stepper.step_fixed([ball], config.fixed_step, config, table)
	return {"label": label, "before": before, "after": {"position_m": [ball.position.x, ball.position.y],
		"phase": ball.phase, "pocket_id": ball.pocket_id, "vertical_velocity_m_s": ball.vertical_velocity}, "events": stepper.drain_events()}

func snapshot(balls: Array[BallState]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for ball in balls:
		result.append({"id": ball.id, "number": ball.number, "position_m": [ball.position.x, ball.position.y],
			"height_m": ball.height, "velocity_m_s": [ball.velocity.x, ball.velocity.y],
			"vertical_velocity_m_s": ball.vertical_velocity, "angular_velocity_rad_s": [ball.angular_velocity.x, ball.angular_velocity.y, ball.angular_velocity.z],
			"phase": ball.phase, "pocket_id": ball.pocket_id})
	return result

func config_parameters(config: PhysicsConfig) -> Dictionary:
	return {"fixed_step_s": config.fixed_step, "gravity_m_s2": config.gravity, "ball_mass_kg": config.ball_mass,
		"ball_restitution": config.ball_restitution, "ball_friction": config.ball_friction,
		"cushion_restitution": config.cushion_restitution, "cushion_friction": config.cushion_friction,
		"sliding_friction": config.sliding_friction, "rolling_resistance": config.rolling_resistance,
		"spinning_friction": config.spinning_friction, "sleep_speed_threshold_m_s": config.sleep_speed_threshold,
		"sleep_spin_threshold_rad_s": config.sleep_spin_threshold, "max_speed_m_s": config.max_speed,
		"max_substep_travel_fraction": config.max_substep_travel_fraction,
		"max_collision_iterations": config.max_collision_iterations}

func total_energy(balls: Array[Dictionary], config: PhysicsConfig) -> float:
	var result := 0.0
	var inertia := 0.4 * config.ball_mass * BallState.RADIUS * BallState.RADIUS
	for ball in balls:
		var velocity: Array = ball.velocity_m_s
		var angular: Array = ball.angular_velocity_rad_s
		result += 0.5 * config.ball_mass * (float(velocity[0]) ** 2 + float(velocity[1]) ** 2)
		result += 0.5 * inertia * (float(angular[0]) ** 2 + float(angular[1]) ** 2 + float(angular[2]) ** 2)
		result += 0.5 * config.ball_mass * float(ball.vertical_velocity_m_s) ** 2
	return result

func energy_breakdown(balls: Array[Dictionary], config: PhysicsConfig) -> Dictionary:
	var translational := 0.0
	var rotational := 0.0
	var vertical := 0.0
	var inertia := 0.4 * config.ball_mass * BallState.RADIUS * BallState.RADIUS
	for ball in balls:
		var velocity: Array = ball.velocity_m_s
		var angular: Array = ball.angular_velocity_rad_s
		translational += 0.5 * config.ball_mass * (float(velocity[0]) ** 2 + float(velocity[1]) ** 2)
		rotational += 0.5 * inertia * (float(angular[0]) ** 2 + float(angular[1]) ** 2 + float(angular[2]) ** 2)
		vertical += 0.5 * config.ball_mass * float(ball.vertical_velocity_m_s) ** 2
	return {"translation_j": translational, "rotation_j": rotational, "vertical_j": vertical,
		"total_j": translational + rotational + vertical}

func momentum(balls: Array[Dictionary], config: PhysicsConfig) -> Array[float]:
	var result := Vector3.ZERO
	for ball in balls:
		var velocity: Array = ball.velocity_m_s
		result += Vector3(float(velocity[0]), float(ball.vertical_velocity_m_s), float(velocity[1])) * config.ball_mass
	return [result.x, result.y, result.z]

func evaluate_convergence() -> Dictionary:
	var comparisons: Array[Dictionary] = []
	var worst_position := {"error_m": 0.0}
	var worst_angle := {"error_deg": 0.0}
	for name in ["head_on", "cut_positive", "cut_negative", "phase_head_on", "pure_rolling", "rail_spin_positive", "rail_spin_negative"]:
		var phases := [0.0, 0.25, 0.5, 0.75] if name == "phase_head_on" else [-1.0]
		for phase in phases:
			var samples: Array[Dictionary] = []
			for resolution in RESOLUTIONS:
				for record in records:
					if record.case == name and int(record.resolution_hz) == resolution and is_equal_approx(float(record.contact_phase_fraction), float(phase)):
						samples.append(record)
			for index in range(samples.size() - 1):
				var low: Dictionary = samples[index]
				var high: Dictionary = samples[index + 1]
				var pos_error := terminal_position_difference(low.terminal_balls, high.terminal_balls)
				var angle_error := terminal_direction_difference(low.terminal_balls, high.terminal_balls)
				var row := {"case": name, "contact_phase_fraction": phase,
					"from_hz": low.resolution_hz, "to_hz": high.resolution_hz,
					"max_ball_endpoint_error_m": pos_error, "max_ball_direction_error_deg": angle_error,
				"within_0_5mm_and_0_1deg": pos_error <= 0.0005 and angle_error <= 0.1}
				comparisons.append(row)
				if pos_error > float(worst_position.error_m): worst_position = {"error_m": pos_error, "case": name, "phase": phase, "from_hz": low.resolution_hz, "to_hz": high.resolution_hz}
				if angle_error > float(worst_angle.error_deg): worst_angle = {"error_deg": angle_error, "case": name, "phase": phase, "from_hz": low.resolution_hz, "to_hz": high.resolution_hz}
				if not row.within_0_5mm_and_0_1deg: failures.append("%s phase %s %d->%d: %.9f m, %.6f deg" % [name, phase, low.resolution_hz, high.resolution_hz, pos_error, angle_error])
	return {"successive_resolution_comparisons": comparisons, "worst_endpoint_error": worst_position,
		"worst_direction_error": worst_angle, "threshold_misses": failures}

func evaluate_analytic_checks() -> Array[Dictionary]:
	var checks: Array[Dictionary] = []
	for name in ["analytic_head_on", "analytic_cut"]:
		var record: Dictionary = {}
		for candidate in records:
			if candidate.case == name and int(candidate.resolution_hz) == 1920: record = candidate
		if record.is_empty(): continue
		var actual: Array = record.terminal_balls
		var expected_first := Vector2.ZERO
		var expected_second := Vector2(2.0, 0.0)
		if name == "analytic_cut":
			var b := 0.025
			var nx := sqrt(BALL_DIAMETER * BALL_DIAMETER - b * b) / BALL_DIAMETER
			var ny := -b / BALL_DIAMETER
			var normal := Vector2(nx, ny)
			expected_first = Vector2(2.0, 0.0) - normal * 2.0 * nx
			expected_second = normal * 2.0 * nx
		var first_velocity: Array = actual[0].velocity_m_s
		var second_velocity: Array = actual[1].velocity_m_s
		var first_error := Vector2(float(first_velocity[0]), float(first_velocity[1])).distance_to(expected_first)
		var second_error := Vector2(float(second_velocity[0]), float(second_velocity[1])).distance_to(expected_second)
		var momentum_error := Vector2(record.terminal_momentum_kg_m_s[0], record.terminal_momentum_kg_m_s[2]).distance_to(Vector2(2.0 * BallState.MASS, 0.0))
		var expected_energy := 0.5 * BallState.MASS * 2.0 * 2.0
		var energy_error := absf(float(record.terminal_energy_j) - expected_energy)
		checks.append({"case": name, "resolution_hz": 1920, "expected_first_velocity_m_s": [expected_first.x, expected_first.y],
			"expected_second_velocity_m_s": [expected_second.x, expected_second.y], "first_velocity_error_m_s": first_error,
			"second_velocity_error_m_s": second_error, "linear_momentum_error_kg_m_s": momentum_error,
			"total_energy_error_j_including_rotation": energy_error,
			"initial_linear_energy_j": expected_energy, "terminal_total_energy_j": record.terminal_energy_j,
			"meets_0_1_percent_momentum_and_energy": momentum_error <= 0.002 * BallState.MASS and energy_error <= expected_energy * 0.001})
	var rolling_record: Dictionary = {}
	for candidate in records:
		if candidate.case == "pure_rolling" and int(candidate.resolution_hz) == 1920: rolling_record = candidate
	if not rolling_record.is_empty():
		var initial_ball: Dictionary = rolling_record.initial_balls[0]
		var final_ball: Dictionary = rolling_record.terminal_balls[0]
		var initial_velocity: Array = initial_ball.velocity_m_s
		var initial_speed := Vector2(float(initial_velocity[0]), float(initial_velocity[1])).length()
		var acceleration := float(rolling_record.initial_parameters.rolling_resistance) * float(rolling_record.initial_parameters.gravity_m_s2)
		var duration := float(rolling_record.duration_s)
		var expected_distance := initial_speed * duration - 0.5 * acceleration * duration * duration
		var actual_position: Array = final_ball.position_m; var start_position: Array = initial_ball.position_m
		var actual_distance := Vector2(float(actual_position[0]) - float(start_position[0]), float(actual_position[1]) - float(start_position[1])).length()
		var expected_speed := initial_speed - acceleration * duration
		var final_velocity: Array = final_ball.velocity_m_s
		var actual_speed := Vector2(float(final_velocity[0]), float(final_velocity[1])).length()
		var translational_energy := 0.5 * float(rolling_record.initial_parameters.ball_mass_kg) * actual_speed * actual_speed
		var angular: Array = final_ball.angular_velocity_rad_s
		var inertia := 0.4 * float(rolling_record.initial_parameters.ball_mass_kg) * BallState.RADIUS * BallState.RADIUS
		var rotational_energy := 0.5 * inertia * (float(angular[0]) ** 2 + float(angular[1]) ** 2 + float(angular[2]) ** 2)
		checks.append({"case": "pure_rolling", "resolution_hz": 1920, "expected_distance_m": expected_distance,
			"actual_distance_m": actual_distance, "distance_error_m": absf(actual_distance - expected_distance),
			"expected_speed_m_s": expected_speed, "actual_speed_m_s": actual_speed,
			"speed_error_m_s": absf(actual_speed - expected_speed), "terminal_translational_energy_j": translational_energy,
			"terminal_rotational_energy_j": rotational_energy, "terminal_total_energy_j": translational_energy + rotational_energy,
			"meets_1_percent_rolling_distance": absf(actual_distance - expected_distance) <= expected_distance * 0.01})
	return checks

func evaluate_mirrors() -> Array[Dictionary]:
	var checks: Array[Dictionary] = []
	for resolution in RESOLUTIONS:
		for pair in [["cut_positive", "cut_negative"], ["rail_spin_positive", "rail_spin_negative"]]:
			var positive: Dictionary = {}; var negative: Dictionary = {}
			for record in records:
				if int(record.resolution_hz) != resolution: continue
				if record.case == pair[0]: positive = record
				if record.case == pair[1]: negative = record
			if positive.is_empty() or negative.is_empty(): continue
			var a: Dictionary = positive.terminal_balls[0]; var b: Dictionary = negative.terminal_balls[0]
			var ap: Array = a.position_m; var bp: Array = b.position_m
			var av: Array = a.velocity_m_s; var bv: Array = b.velocity_m_s
			var aw: Array = a.angular_velocity_rad_s; var bw: Array = b.angular_velocity_rad_s
			var position_error := 0.0; var velocity_error := 0.0; var spin_error := 0.0
			if pair[0] == "cut_positive":
				position_error = Vector2(float(ap[0]) - float(bp[0]), float(ap[1]) + float(bp[1])).length()
				velocity_error = Vector2(float(av[0]) - float(bv[0]), float(av[1]) + float(bv[1])).length()
				spin_error = Vector3(float(aw[0]) + float(bw[0]), float(aw[1]) + float(bw[1]), float(aw[2]) - float(bw[2])).length()
			else:
				position_error = Vector2(float(ap[0]) + float(bp[0]) + 0.6, float(ap[1]) - float(bp[1])).length()
				velocity_error = Vector2(float(av[0]) + float(bv[0]), float(av[1]) - float(bv[1])).length()
				spin_error = Vector3(float(aw[0]) - float(bw[0]), float(aw[1]) + float(bw[1]), float(aw[2]) + float(bw[2])).length()
			checks.append({"positive_case": pair[0], "negative_case": pair[1], "resolution_hz": resolution,
				"reflected_endpoint_error_m": position_error, "reflected_velocity_error_m_s": velocity_error,
				"reflected_spin_error_rad_s": spin_error, "event_count_equal": positive.event_metrics.counts == negative.event_metrics.counts})
	return checks

func terminal_position_difference(first: Array, second: Array) -> float:
	var worst := 0.0
	for index in range(mini(first.size(), second.size())):
		var a: Array = first[index].position_m
		var b: Array = second[index].position_m
		worst = maxf(worst, Vector2(float(a[0]), float(a[1])).distance_to(Vector2(float(b[0]), float(b[1]))))
	return worst

func terminal_direction_difference(first: Array, second: Array) -> float:
	var worst := 0.0
	for index in range(mini(first.size(), second.size())):
		var av: Array = first[index].velocity_m_s
		var bv: Array = second[index].velocity_m_s
		var a := Vector2(float(av[0]), float(av[1]))
		var b := Vector2(float(bv[0]), float(bv[1]))
		if a.length_squared() > 1.0e-6 and b.length_squared() > 1.0e-6:
			worst = maxf(worst, rad_to_deg(absf(a.angle_to(b))))
	return worst

func write_json(filename: String, value: Variant) -> void:
	var file := FileAccess.open(output_dir.path_join(filename), FileAccess.WRITE)
	file.store_string(JSON.stringify(value, "\t", false))
	file.close()

func source_sha256(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return "unavailable"
	var hasher := HashingContext.new()
	hasher.start(HashingContext.HASH_SHA256)
	hasher.update(file.get_buffer(file.get_length()))
	return hasher.finish().hex_encode()

func write_csv() -> void:
	var lines := ["case,pocket_id,resolution_hz,phase_fraction,duration_s,ball_index,initial_x_m,initial_y_m,initial_vx_m_s,initial_vy_m_s,initial_wx_rad_s,initial_wy_rad_s,initial_wz_rad_s,final_x_m,final_y_m,final_vx_m_s,final_vy_m_s,final_wx_rad_s,final_wy_rad_s,final_wz_rad_s,phase,pocket,initial_energy_j,final_energy_j,initial_translation_j,initial_rotation_j,final_translation_j,final_rotation_j,initial_px,initial_py,initial_pz,final_px,final_py,final_pz,ball_contacts,rails,pockets,off_table,first_contact_time_s,first_rail_time_s,source_commit,physics_stepper_sha256,table_spec_sha256,godot_version,harness_sha256"]
	for record in records:
		var initial: Array = record.initial_balls
		var terminal: Array = record.terminal_balls
		for index in range(mini(initial.size(), terminal.size())):
			var a: Dictionary = initial[index]
			var b: Dictionary = terminal[index]
			var av: Array = a.get("velocity_m_s", [0.0, 0.0]); var aw: Array = a.get("angular_velocity_rad_s", [0.0, 0.0, 0.0])
			var bv: Array = b.get("velocity_m_s", [0.0, 0.0]); var bw: Array = b.get("angular_velocity_rad_s", [0.0, 0.0, 0.0])
			var ap: Array = a.get("position_m", [0.0, 0.0]); var bp: Array = b.get("position_m", [0.0, 0.0])
			var counts: Dictionary = record.event_metrics.counts
			var momentum_a: Array = record.initial_momentum_kg_m_s; var momentum_b: Array = record.terminal_momentum_kg_m_s
			var energy_a: Dictionary = record.get("initial_energy_components_j", {"translation_j": 0.0, "rotation_j": 0.0})
			var energy_b: Dictionary = record.get("terminal_energy_components_j", {"translation_j": 0.0, "rotation_j": 0.0})
			lines.append(",".join([str(record.case), str(record.get("pocket_id", -1)), str(record.resolution_hz), str(record.contact_phase_fraction), str(record.duration_s), str(index),
				str(ap[0]), str(ap[1]), str(av[0]), str(av[1]), str(aw[0]), str(aw[1]), str(aw[2]),
				str(bp[0]), str(bp[1]), str(bv[0]), str(bv[1]), str(bw[0]), str(bw[1]), str(bw[2]), str(b.phase), str(b.pocket_id),
				str(record.initial_energy_j), str(record.terminal_energy_j), str(energy_a.translation_j), str(energy_a.rotation_j), str(energy_b.translation_j), str(energy_b.rotation_j),
				str(momentum_a[0]), str(momentum_a[1]), str(momentum_a[2]),
				str(momentum_b[0]), str(momentum_b[1]), str(momentum_b[2]), str(counts.get("ball_contact", 0)), str(counts.get("rail", 0)),
				str(counts.get("pocket", 0)), str(counts.get("off_table", 0)), str(record.event_metrics.first_contact_time_s), str(record.event_metrics.get("first_rail_time_s", -1.0)),
				"runtime", source_sha256("res://scripts/sim/physics_stepper.gd"), source_sha256("res://scripts/sim/table_spec.gd"), Engine.get_version_info().string,
				source_sha256("res://tests/physics_precision.gd")]))
	var file := FileAccess.open(output_dir.path_join("runs.csv"), FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n")
	file.close()
