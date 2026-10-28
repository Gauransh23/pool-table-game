extends RefCounted
class_name CueStrikeModel

const MAX_TIP_OFFSET := 0.5

var last_miscue: bool = false
var last_squirt_angle: float = 0.0


func apply(
	ball: BallState,
	direction: Vector2,
	cue_speed: float,
	tip_offset: Vector2,
	cue_elevation: float,
	config: PhysicsConfig
) -> bool:
	last_miscue = false
	last_squirt_angle = 0.0
	if direction.length_squared() < 1.0e-10 or cue_speed <= 0.0 or not ball.is_on_table():
		return false
	if tip_offset.length() > MAX_TIP_OFFSET + 1.0e-6:
		last_miscue = true
		return false
	var planar_direction := direction.normalized()
	var elevation := clampf(cue_elevation, 0.0, deg_to_rad(65.0))
	var axis := Vector3(planar_direction.x * cos(elevation), -sin(elevation), planar_direction.y * cos(elevation)).normalized()
	var lateral := Vector3(-planar_direction.y, 0.0, planar_direction.x)
	var tip := tip_offset
	var contact_up := Vector3.UP - axis * Vector3.UP.dot(axis)
	if contact_up.length_squared() < 1.0e-8:
		contact_up = Vector3.RIGHT - axis * Vector3.RIGHT.dot(axis)
	contact_up = contact_up.normalized()
	var offset_sq := tip.length_squared()
	var normal_component := sqrt(maxf(0.0, 1.0 - offset_sq))
	var contact_arm := BallState.RADIUS * (-axis * normal_component + lateral * tip.x + contact_up * tip.y)
	var cue_mass := maxf(0.01, config.cue_mass)
	var ball_mass := maxf(0.01, config.ball_mass)
	var ball_to_cue_mass := ball_mass / cue_mass
	var denominator := 1.0 + ball_to_cue_mass + 2.5 * offset_sq
	var energy_discriminant := 1.0 - denominator * (1.0 - config.cue_collision_efficiency) / ball_to_cue_mass
	if energy_discriminant < 0.0:
		last_miscue = true
		return false
	var ball_speed := cue_speed * (1.0 + sqrt(energy_discriminant)) / denominator
	if absf(tip.x) > 1.0e-7:
		var beta := absf(tip.x)
		var end_mass := maxf(0.001, config.cue_end_mass)
		var ball_to_end_mass := ball_mass / end_mass
		var numerator := 2.5 * beta * sqrt(maxf(0.0, 1.0 - beta * beta))
		var squirt_denominator := 1.0 + ball_to_end_mass + 2.5 * (1.0 - beta * beta)
		last_squirt_angle = signf(tip.x) * atan(numerator / squirt_denominator)
	var squirted_planar := planar_direction.rotated(-last_squirt_angle)
	var impulse_axis := Vector3(squirted_planar.x * cos(elevation), axis.y, squirted_planar.y * cos(elevation)).normalized()
	var impulse := impulse_axis * ball_mass * ball_speed
	var inertia := 0.4 * ball_mass * BallState.RADIUS * BallState.RADIUS
	var new_linear := Vector3(ball.velocity.x, ball.vertical_velocity, ball.velocity.y) + impulse / ball_mass
	ball.velocity = Vector2(new_linear.x, new_linear.z)
	ball.vertical_velocity = new_linear.y
	ball.angular_velocity += contact_arm.cross(impulse) / inertia
	ball.phase = BallState.Phase.AIRBORNE if ball.vertical_velocity > 0.035 else BallState.Phase.IN_PLAY
	return true
