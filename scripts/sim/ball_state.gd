extends RefCounted
class_name BallState

const RADIUS := 0.028575
const MASS := 0.168
const INERTIA := 0.4 * MASS * RADIUS * RADIUS
const OFF_TABLE_TERMINAL_HEIGHT := -0.12

enum Phase { IN_PLAY, AIRBORNE, FALLING, POCKETED, OFF_TABLE }

var id: int
var number: int
var position: Vector2
var height: float = RADIUS
var velocity: Vector2 = Vector2.ZERO
var vertical_velocity: float = 0.0
var angular_velocity: Vector3 = Vector3.ZERO
var orientation: Quaternion = Quaternion.IDENTITY
var phase: Phase = Phase.IN_PLAY
var pocket_id: int = -1


func _init(p_id: int = 0, p_number: int = 0, p_position: Vector2 = Vector2.ZERO) -> void:
	id = p_id
	number = p_number
	position = p_position


func duplicate_state() -> BallState:
	var copy := BallState.new(id, number, position)
	copy.height = height
	copy.velocity = velocity
	copy.vertical_velocity = vertical_velocity
	copy.angular_velocity = angular_velocity
	copy.orientation = orientation
	copy.phase = phase
	copy.pocket_id = pocket_id
	return copy


func is_active() -> bool:
	return phase == Phase.IN_PLAY or phase == Phase.AIRBORNE or phase == Phase.FALLING


func is_on_table() -> bool:
	return phase == Phase.IN_PLAY or phase == Phase.AIRBORNE


func canonical_state() -> PackedFloat64Array:
	return PackedFloat64Array([
		float(id), float(number), position.x, position.y, height,
		velocity.x, velocity.y, vertical_velocity,
		angular_velocity.x, angular_velocity.y, angular_velocity.z,
		orientation.x, orientation.y, orientation.z, orientation.w,
		float(phase), float(pocket_id),
	])


func advance_orientation(delta: float) -> void:
	var angular_speed := angular_velocity.length()
	if angular_speed > 1.0e-7:
		var rotation_step := Quaternion(angular_velocity / angular_speed, angular_speed * delta)
		orientation = (rotation_step * orientation).normalized()
