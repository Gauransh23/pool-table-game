extends RefCounted
class_name TableSpec

const NINE_FOOT_LENGTH := 2.54
const NINE_FOOT_WIDTH := 1.27

var half_size: Vector2 = Vector2(NINE_FOOT_LENGTH * 0.5, NINE_FOOT_WIDTH * 0.5)
var corner_mouth: float = 0.116
var side_mouth: float = 0.129
var pocket_depth: float = 0.13
var cushion_nose_height: float = BallState.RADIUS * 1.27
var _cached_segments: Array[Dictionary] = []
var _cached_half_size: Vector2 = Vector2.ZERO
var _cached_corner_mouth: float = -1.0
var _cached_side_mouth: float = -1.0
var _cached_pocket_depth: float = -1.0


func rail_segments() -> Array[Dictionary]:
	if _cached_segments.is_empty() or _cached_half_size != half_size or not is_equal_approx(_cached_corner_mouth, corner_mouth) or not is_equal_approx(_cached_side_mouth, side_mouth) or not is_equal_approx(_cached_pocket_depth, pocket_depth):
		_cached_segments = _build_rail_segments()
		_cached_half_size = half_size
		_cached_corner_mouth = corner_mouth
		_cached_side_mouth = side_mouth
		_cached_pocket_depth = pocket_depth
	return _cached_segments


func _build_rail_segments() -> Array[Dictionary]:
	var segments: Array[Dictionary] = []
	var half_x := half_size.x
	var half_z := half_size.y
	var corner_gap := corner_mouth / sqrt(2.0)
	var side_gap := side_mouth * 0.5
	for side_sign in [-1, 1]:
		var side_sign_value: float = float(side_sign)
		var z: float = side_sign_value * half_z
		var inward := Vector2(0.0, -side_sign_value)
		_add_face(segments, Vector2(-half_x + corner_gap, z), Vector2(-side_gap, z), inward)
		_add_face(segments, Vector2(side_gap, z), Vector2(half_x - corner_gap, z), inward)
	for end_sign in [-1, 1]:
		var end_sign_value: float = float(end_sign)
		var x: float = end_sign_value * half_x
		var inward := Vector2(-end_sign_value, 0.0)
		_add_face(segments, Vector2(x, -half_z + corner_gap), Vector2(x, half_z - corner_gap), inward)
	_add_corner_jaws(segments)
	_add_side_jaws(segments)
	return segments


func pocket_at(position: Vector2) -> int:
	var x_limit := half_size.x - BallState.RADIUS
	var z_limit := half_size.y - BallState.RADIUS
	if absf(position.x) > x_limit and absf(position.y) > z_limit:
		for x_sign in [-1.0, 1.0]:
			for z_sign in [-1.0, 1.0]:
				if x_sign * position.x > x_limit and z_sign * position.y > z_limit:
					return _corner_id(x_sign, z_sign)
	if absf(position.y) > z_limit and absf(position.x) < side_mouth * 0.5 - BallState.RADIUS * 0.18:
		return 4 if position.y > 0.0 else 5
	return -1


func outside_table(position: Vector2) -> bool:
	return absf(position.x) > half_size.x or absf(position.y) > half_size.y


func _add_face(segments: Array[Dictionary], a: Vector2, b: Vector2, inward: Vector2) -> void:
	if a.distance_squared_to(b) > 1.0e-8:
		segments.append({"a": a, "b": b, "inward": inward, "jaw": false})


func _add_jaw(segments: Array[Dictionary], a: Vector2, b: Vector2) -> void:
	var tangent := b - a
	var inward := Vector2(-tangent.y, tangent.x).normalized()
	var middle := (a + b) * 0.5
	if inward.dot(-middle) < 0.0:
		inward = -inward
	segments.append({"a": a, "b": b, "inward": inward, "jaw": true})


func _add_corner_jaws(segments: Array[Dictionary]) -> void:
	var half_x := half_size.x
	var half_z := half_size.y
	var mouth_half := corner_mouth / sqrt(2.0)
	var throat_offset := pocket_depth
	for x_sign in [-1.0, 1.0]:
		for z_sign in [-1.0, 1.0]:
			var throat := Vector2(x_sign * (half_x + throat_offset), z_sign * (half_z + throat_offset))
			_add_jaw(segments, Vector2(x_sign * (half_x - mouth_half), z_sign * half_z), throat)
			_add_jaw(segments, Vector2(x_sign * half_x, z_sign * (half_z - mouth_half)), throat)


func _add_side_jaws(segments: Array[Dictionary]) -> void:
	var mouth_half := side_mouth * 0.5
	for z_sign in [-1.0, 1.0]:
		var throat := Vector2(0.0, z_sign * (half_size.y + pocket_depth))
		_add_jaw(segments, Vector2(-mouth_half, z_sign * half_size.y), throat)
		_add_jaw(segments, Vector2(mouth_half, z_sign * half_size.y), throat)


func _corner_id(x_sign: float, z_sign: float) -> int:
	if x_sign < 0.0:
		return 0 if z_sign > 0.0 else 1
	return 2 if z_sign > 0.0 else 3
