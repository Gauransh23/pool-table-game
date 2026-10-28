extends RefCounted
class_name PhysicsStepper

const CONTACT_EPSILON := 1.0e-8
const POSITION_SLOP := 0.00008
const POSITION_CORRECTION := 0.82

var _accumulator: float = 0.0
var tick_count: int = 0


func advance(balls: Array, elapsed: float, config: PhysicsConfig, table: TableSpec) -> int:
	if elapsed <= 0.0:
		return 0
	_accumulator += elapsed
	var ticks := 0
	while _accumulator + 1.0e-12 >= config.fixed_step:
		step_fixed(balls, config.fixed_step, config, table)
		_accumulator -= config.fixed_step
		ticks += 1
	tick_count += 1
	return ticks


func step_fixed(balls: Array, delta: float, config: PhysicsConfig, table: TableSpec) -> void:
	if delta <= 0.0:
		return
	var fastest := 0.0
	for ball in balls:
		if ball.is_on_table():
			fastest = maxf(maxf(fastest, ball.velocity.length()), absf(ball.vertical_velocity))
	var travel_limit := maxf(0.006, BallState.RADIUS * config.max_substep_travel_fraction)
	var substeps := maxi(1, ceili(fastest * delta / travel_limit))
	var sub_delta := delta / float(substeps)
	for substep in range(substeps):
		_integrate_balls(balls, sub_delta, config, table)
		for iteration in range(config.max_collision_iterations):
			var any_contact := false
			for first_index in range(balls.size()):
				var first: BallState = balls[first_index]
				if not first.is_on_table():
					continue
				for second_index in range(first_index + 1, balls.size()):
					var second: BallState = balls[second_index]
					if not second.is_on_table():
						continue
					any_contact = _resolve_ball_pair(first, second, config) or any_contact
			for ball in balls:
				if ball.is_on_table():
					any_contact = _resolve_rails(ball, config, table) or any_contact
			if not any_contact:
				break
		_classify_exits(balls, table)


func contact_slip(ball: BallState) -> Vector2:
	return Vector2(
		ball.velocity.x + BallState.RADIUS * ball.angular_velocity.z,
		ball.velocity.y - BallState.RADIUS * ball.angular_velocity.x
	)


func _integrate_balls(balls: Array, delta: float, config: PhysicsConfig, table: TableSpec) -> void:
	for ball in balls:
		if ball.phase == BallState.Phase.POCKETED:
			continue
		if ball.phase == BallState.Phase.OFF_TABLE:
			ball.vertical_velocity -= config.gravity * delta
			ball.height += ball.vertical_velocity * delta
			ball.position += ball.velocity * delta
			ball.advance_orientation(delta)
			continue
		if ball.phase == BallState.Phase.FALLING:
			ball.vertical_velocity -= config.gravity * delta
			ball.height += ball.vertical_velocity * delta
			ball.velocity *= exp(-1.1 * delta)
			ball.position += ball.velocity * delta
			if ball.height < -0.12:
				ball.phase = BallState.Phase.POCKETED
			continue
		if ball.height > BallState.RADIUS + 1.0e-5 or ball.vertical_velocity > 1.0e-4:
			ball.phase = BallState.Phase.AIRBORNE
			ball.vertical_velocity -= config.gravity * delta
			ball.height += ball.vertical_velocity * delta
			ball.position += ball.velocity * delta
			if ball.height < BallState.RADIUS:
				ball.height = BallState.RADIUS
				ball.vertical_velocity = -ball.vertical_velocity * 0.18
				if absf(ball.vertical_velocity) < 0.08:
					ball.vertical_velocity = 0.0
					ball.phase = BallState.Phase.IN_PLAY
		else:
			ball.phase = BallState.Phase.IN_PLAY
			ball.height = BallState.RADIUS
			ball.vertical_velocity = 0.0
			_apply_cloth_friction(ball, delta, config)
			ball.position += ball.velocity * delta
		ball.advance_orientation(delta)
		if ball.velocity.length() < config.sleep_speed_threshold and ball.angular_velocity.length() < config.sleep_spin_threshold and ball.phase == BallState.Phase.IN_PLAY:
			ball.velocity = Vector2.ZERO
			ball.angular_velocity = Vector3.ZERO
			ball.vertical_velocity = 0.0
			ball.height = BallState.RADIUS


func _apply_cloth_friction(ball: BallState, delta: float, config: PhysicsConfig) -> void:
	var slip := contact_slip(ball)
	var mass := config.ball_mass
	var inertia := 0.4 * mass * BallState.RADIUS * BallState.RADIUS
	var rotational_inverse_mass := BallState.RADIUS * BallState.RADIUS / inertia
	if slip.length() > 0.0005:
		var impulse_limit := config.sliding_friction * mass * config.gravity * delta
		var impulse_needed := slip.length() / (1.0 / mass + rotational_inverse_mass)
		var impulse_magnitude := minf(impulse_limit, impulse_needed)
		_apply_cloth_impulse(ball, -slip.normalized() * impulse_magnitude, inertia, mass)
	else:
		var speed := ball.velocity.length()
		if speed > 1.0e-7:
			var rolling_impulse := minf(config.rolling_resistance * mass * config.gravity * delta, speed * mass)
			_apply_cloth_impulse(ball, -ball.velocity.normalized() * rolling_impulse, inertia, mass)
	ball.angular_velocity.y *= exp(-config.spin_decay_rate * delta)


func _apply_cloth_impulse(ball: BallState, planar_impulse: Vector2, inertia: float, mass: float) -> void:
	ball.velocity += planar_impulse / mass
	var impulse_3d := Vector3(planar_impulse.x, 0.0, planar_impulse.y)
	var arm := Vector3(0.0, -BallState.RADIUS, 0.0)
	ball.angular_velocity += arm.cross(impulse_3d) / inertia


func _resolve_ball_pair(first: BallState, second: BallState, config: PhysicsConfig) -> bool:
	var first_position := Vector3(first.position.x, first.height, first.position.y)
	var second_position := Vector3(second.position.x, second.height, second.position.y)
	var separation := second_position - first_position
	var distance_sq := separation.length_squared()
	var diameter := BallState.RADIUS * 2.0
	if distance_sq >= diameter * diameter:
		return false
	var distance := sqrt(maxf(distance_sq, CONTACT_EPSILON))
	var normal := separation / distance if distance_sq > CONTACT_EPSILON else Vector3.RIGHT
	var penetration := diameter - distance
	var correction := maxf(0.0, penetration - POSITION_SLOP) * POSITION_CORRECTION * 0.5
	first.position -= Vector2(normal.x, normal.z) * correction
	second.position += Vector2(normal.x, normal.z) * correction
	first.height -= normal.y * correction
	second.height += normal.y * correction
	var first_arm := normal * BallState.RADIUS
	var second_arm := -normal * BallState.RADIUS
	var relative := _contact_velocity(second, second_arm) - _contact_velocity(first, first_arm)
	var normal_speed := relative.dot(normal)
	if normal_speed >= 0.0:
		return true
	var inverse_mass := 1.0 / config.ball_mass
	var inverse_inertia := 1.0 / (0.4 * config.ball_mass * BallState.RADIUS * BallState.RADIUS)
	var normal_denominator := 2.0 * inverse_mass
	var normal_impulse := -(1.0 + config.ball_restitution) * normal_speed / normal_denominator
	var normal_vector := normal * normal_impulse
	_apply_impulse(first, -normal_vector, first_arm, config.ball_mass, inverse_inertia)
	_apply_impulse(second, normal_vector, second_arm, config.ball_mass, inverse_inertia)
	var tangent_velocity := relative - normal * normal_speed
	var tangent_speed := tangent_velocity.length()
	if tangent_speed > CONTACT_EPSILON and config.ball_friction > 0.0:
		var tangent := tangent_velocity / tangent_speed
		var first_torque_axis := first_arm.cross(tangent)
		var second_torque_axis := second_arm.cross(tangent)
		var tangent_denominator := 2.0 * inverse_mass + (first_torque_axis.length_squared() + second_torque_axis.length_squared()) * inverse_inertia
		var desired_tangent_impulse := tangent_speed / tangent_denominator
		var tangent_impulse := minf(desired_tangent_impulse, config.ball_friction * normal_impulse)
		var tangent_vector := -tangent * tangent_impulse
		_apply_impulse(first, -tangent_vector, first_arm, config.ball_mass, inverse_inertia)
		_apply_impulse(second, tangent_vector, second_arm, config.ball_mass, inverse_inertia)
	return true


func _resolve_rails(ball: BallState, config: PhysicsConfig, table: TableSpec) -> bool:
	var touched := false
	var ball_center := Vector3(ball.position.x, ball.height, ball.position.y)
	var ball_velocity := Vector3(ball.velocity.x, ball.vertical_velocity, ball.velocity.y)
	var mass := config.ball_mass
	var inertia := 0.4 * mass * BallState.RADIUS * BallState.RADIUS
	for segment in table.rail_segments():
		var a: Vector2 = segment["a"]
		var b: Vector2 = segment["b"]
		var inward: Vector2 = segment["inward"]
		var closest := Geometry2D.get_closest_point_to_segment(ball.position, a, b)
		var offset := ball.position - closest
		var signed_distance := offset.dot(inward)
		if signed_distance < -0.001 or offset.length_squared() >= BallState.RADIUS * BallState.RADIUS:
			continue
		var planar_normal := offset.normalized() if offset.length_squared() > CONTACT_EPSILON else inward
		if planar_normal.dot(inward) < 0.0:
			planar_normal = inward
		var normal := Vector3(planar_normal.x, 0.0, planar_normal.y)
		var distance := offset.length()
		var correction := maxf(0.0, BallState.RADIUS - distance)
		ball.position += planar_normal * correction
		# WPA's recommended nose height is about 63.5% of a ball diameter.
		# In this center-relative contact model that is 0.27 ball radii above center.
		var contact_height := BallState.RADIUS * 0.27
		var arm_horizontal := sqrt(maxf(0.0, BallState.RADIUS * BallState.RADIUS - contact_height * contact_height))
		var arm := Vector3(-planar_normal.x * arm_horizontal, contact_height, -planar_normal.y * arm_horizontal)
		var contact_velocity := ball_velocity + ball.angular_velocity.cross(arm)
		var normal_speed := contact_velocity.dot(normal)
		if normal_speed < 0.0:
			var inverse_inertia := 1.0 / inertia
			var torque_axis := arm.cross(normal)
			var normal_denominator := 1.0 / mass + torque_axis.length_squared() * inverse_inertia
			var normal_impulse := -(1.0 + config.cushion_restitution) * normal_speed / normal_denominator
			var impulse := normal * normal_impulse
			var tangent_velocity := contact_velocity - normal * normal_speed
			if tangent_velocity.length_squared() > CONTACT_EPSILON and config.cushion_friction > 0.0:
				var tangent := tangent_velocity.normalized()
				var tangent_axis := arm.cross(tangent)
				var tangent_denominator := 1.0 / mass + tangent_axis.length_squared() * inverse_inertia
				var desired_tangent_impulse := tangent_velocity.length() / tangent_denominator
				var tangent_impulse := minf(desired_tangent_impulse, config.cushion_friction * normal_impulse)
				impulse -= tangent * tangent_impulse
			_apply_impulse(ball, impulse, arm, mass, 1.0 / inertia)
		ball_velocity = Vector3(ball.velocity.x, ball.vertical_velocity, ball.velocity.y)
		touched = true
	return touched


func _classify_exits(balls: Array, table: TableSpec) -> void:
	for ball in balls:
		if not ball.is_on_table():
			continue
		var pocket := table.pocket_at(ball.position)
		if pocket >= 0 and ball.height <= BallState.RADIUS + 0.002:
			ball.phase = BallState.Phase.FALLING
			ball.pocket_id = pocket
			ball.vertical_velocity = minf(ball.vertical_velocity, -maxf(0.28, ball.velocity.length() * 0.08))
		elif table.outside_table(ball.position):
			ball.phase = BallState.Phase.OFF_TABLE


func _contact_velocity(ball: BallState, arm: Vector3) -> Vector3:
	return Vector3(ball.velocity.x, ball.vertical_velocity, ball.velocity.y) + ball.angular_velocity.cross(arm)


func _apply_impulse(ball: BallState, impulse: Vector3, arm: Vector3, mass: float, inverse_inertia: float) -> void:
	var linear := Vector3(ball.velocity.x, ball.vertical_velocity, ball.velocity.y) + impulse / mass
	ball.velocity = Vector2(linear.x, linear.z)
	ball.vertical_velocity = linear.y
	ball.angular_velocity += arm.cross(impulse) * inverse_inertia
