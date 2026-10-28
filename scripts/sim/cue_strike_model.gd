extends RefCounted
class_name CueStrikeModel

const MAX_TIP_OFFSET := 0.82


func apply(
	ball: BallState,
	direction: Vector2,
	cue_speed: float,
	tip_offset: Vector2,
	cue_elevation: float,
	config: PhysicsConfig
) -> bool:
	if direction.length_squared() < 1.0e-10 or cue_speed <= 0.0 or not ball.is_on_table():
		return false
	var planar_direction := direction.normalized()
	var elevation := clampf(cue_elevation, 0.0, deg_to_rad(65.0))
	var axis := Vector3(planar_direction.x * cos(elevation), sin(elevation), planar_direction.y * cos(elevation)).normalized()
	var lateral := Vector3(-planar_direction.y, 0.0, planar_direction.x)
	var tip := tip_offset.limit_length(MAX_TIP_OFFSET)
	var contact_up := Vector3.UP - axis * Vector3.UP.dot(axis)
	if contact_up.length_squared() < 1.0e-8:
		contact_up = Vector3.RIGHT - axis * Vector3.RIGHT.dot(axis)
	contact_up = contact_up.normalized()
	var offset_sq := minf(tip.length_squared(), MAX_TIP_OFFSET * MAX_TIP_OFFSET)
	var normal_component := sqrt(maxf(0.0, 1.0 - offset_sq))
	var contact_arm := BallState.RADIUS * (-axis * normal_component + lateral * tip.x + contact_up * tip.y)
	var cue_mass := maxf(0.01, config.cue_mass)
	var ball_mass := maxf(0.01, config.ball_mass)
	var impulse_magnitude := (1.0 + config.cue_ball_restitution) * cue_mass * ball_mass / (cue_mass + ball_mass) * cue_speed
	var impulse := axis * impulse_magnitude
	var inertia := 0.4 * ball_mass * BallState.RADIUS * BallState.RADIUS
	var new_linear := Vector3(ball.velocity.x, ball.vertical_velocity, ball.velocity.y) + impulse / ball_mass
	ball.velocity = Vector2(new_linear.x, new_linear.z)
	ball.vertical_velocity = new_linear.y
	ball.angular_velocity += contact_arm.cross(impulse) / inertia
	ball.phase = BallState.Phase.AIRBORNE if ball.vertical_velocity > 0.035 else BallState.Phase.IN_PLAY
	return true
