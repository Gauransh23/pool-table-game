extends RefCounted
class_name TableSpec

const NINE_FOOT_LENGTH := 2.54
const NINE_FOOT_WIDTH := 1.27
const GEOMETRY_EPSILON := 0.000001

var half_size: Vector2 = Vector2(NINE_FOOT_LENGTH * 0.5, NINE_FOOT_WIDTH * 0.5)
var corner_mouth: float = 0.116
var side_mouth: float = 0.129
var pocket_depth: float = 0.13
var corner_shelf: float = 0.035
var side_shelf: float = 0.006
var corner_cut_angle_degrees: float = 142.0
var side_cut_angle_degrees: float = 104.0
var cushion_nose_height: float = BallState.RADIUS * 1.27

var _cached_signature := PackedFloat64Array()
var _cached_definitions: Array[Dictionary] = []
var _cached_segments: Array[Dictionary] = []
var _cached_outline := PackedVector2Array()


func rail_segments() -> Array[Dictionary]:
	_ensure_geometry_cache()
	return _cached_segments


func pocket_definitions() -> Array[Dictionary]:
	_ensure_geometry_cache()
	return _cached_definitions


func cloth_outline() -> PackedVector2Array:
	_ensure_geometry_cache()
	return _cached_outline


func pocket_at(position: Vector2) -> int:
	var corner_gap := corner_mouth / sqrt(2.0)
	if absf(position.y) < half_size.y-corner_gap: return -1
	if absf(position.x) < half_size.x-corner_gap and absf(position.y) < half_size.y: return -1
	for definition in pocket_definitions():
		if _polygon_contains_inclusive(position, _pocket_volume_polygon(definition), GEOMETRY_EPSILON):
			return int(definition["id"])
	return -1


func is_supported(position: Vector2) -> bool:
	# Exact broad phase: all notches lie in the four corner squares or beyond
	# a side mouth. Ordinary bed points need no polygon allocation/query.
	var x := absf(position.x)
	var y := absf(position.y)
	var gap := corner_mouth / sqrt(2.0)
	if x <= half_size.x-gap and y <= half_size.y: return true
	if x <= half_size.x and y <= half_size.y-gap: return true
	return _polygon_contains_inclusive(position, cloth_outline(), GEOMETRY_EPSILON)


func outside_table(position: Vector2) -> bool:
	if absf(position.x) <= half_size.x and absf(position.y) <= half_size.y: return false
	if pocket_at(position) >= 0:
		return false
	return absf(position.x) > half_size.x or absf(position.y) > half_size.y


func _ensure_geometry_cache() -> void:
	var signature := PackedFloat64Array([
		half_size.x, half_size.y, corner_mouth, side_mouth, pocket_depth,
		corner_shelf, side_shelf, corner_cut_angle_degrees, side_cut_angle_degrees,
	])
	if signature == _cached_signature:
		return
	_cached_signature = signature
	_cached_definitions = _build_pocket_definitions()
	_cached_segments = _build_rail_segments(_cached_definitions)
	_cached_outline = _build_cloth_outline(_cached_definitions)


func _build_pocket_definitions() -> Array[Dictionary]:
	var definitions: Array[Dictionary] = []
	var corner_offset := corner_mouth / (2.0 * sqrt(2.0))
	for x_sign in [-1.0, 1.0]:
		for z_sign in [-1.0, 1.0]:
			var outward := Vector2(x_sign, z_sign).normalized()
			var center := Vector2(
				x_sign * (half_size.x - corner_offset),
				z_sign * (half_size.y - corner_offset)
			)
			definitions.append(_make_pocket_definition(
				_corner_id(x_sign, z_sign), center, outward, corner_mouth,
				corner_shelf, corner_cut_angle_degrees, true
			))
	for z_sign in [1.0, -1.0]:
		var outward := Vector2(0.0, z_sign)
		var center := Vector2(0.0, z_sign * half_size.y)
		var id := 4 if z_sign > 0.0 else 5
		definitions.append(_make_pocket_definition(
			id, center, outward, side_mouth, side_shelf, side_cut_angle_degrees, false
		))
	definitions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["id"]) < int(b["id"]))
	return definitions


func _make_pocket_definition(
	id: int,
	center: Vector2,
	outward: Vector2,
	mouth_width: float,
	shelf_depth: float,
	cut_angle_degrees: float,
	is_corner: bool
) -> Dictionary:
	var tangent := Vector2(-outward.y, outward.x)
	var mouth_a := center - tangent * mouth_width * 0.5
	var mouth_b := center + tangent * mouth_width * 0.5
	# WPA angles are inside cuts. These are the small deviations of each jaw
	# from the pocket axis required to make the two cuts symmetric.
	var deviation_from_axis := cut_angle_degrees - (135.0 if is_corner else 90.0)
	var deviation := deg_to_rad(clampf(deviation_from_axis, 0.0, 44.0))
	var jaw_a_unit := (outward * cos(deviation) + tangent * sin(deviation)).normalized()
	var jaw_b_unit := (outward * cos(deviation) - tangent * sin(deviation)).normalized()
	var outward_projection := maxf(0.0001, cos(deviation))
	var fall_a := mouth_a + jaw_a_unit * (shelf_depth / outward_projection)
	var fall_b := mouth_b + jaw_b_unit * (shelf_depth / outward_projection)
	var back_a := mouth_a + jaw_a_unit * (pocket_depth / outward_projection)
	var back_b := mouth_b + jaw_b_unit * (pocket_depth / outward_projection)
	var opening := PackedVector2Array([fall_a, fall_b, back_b, back_a])
	var support_edges: Array[Dictionary] = [
		{"a": mouth_a, "b": fall_a},
		{"a": fall_a, "b": fall_b},
		{"a": fall_b, "b": mouth_b},
	]
	return {
		"id": id,
		"mouth_a": mouth_a,
		"mouth_b": mouth_b,
		"outward": outward,
		"mouth_center": center,
		"fall_a": fall_a,
		"fall_b": fall_b,
		"back_a": back_a,
		"back_b": back_b,
		"opening": opening,
		"support_edges": support_edges,
		"shelf_depth": shelf_depth,
		"cut_angle_degrees": cut_angle_degrees,
		"jaw_a_unit": jaw_a_unit,
		"jaw_b_unit": jaw_b_unit,
		"jaw_a_back": back_a,
		"jaw_b_back": back_b,
	}


func _build_rail_segments(definitions: Array[Dictionary]) -> Array[Dictionary]:
	var segments: Array[Dictionary] = []
	var half_x := half_size.x
	var half_z := half_size.y
	var corner_gap := corner_mouth / sqrt(2.0)
	var side_gap := side_mouth * 0.5
	for side_sign in [-1.0, 1.0]:
		var z: float = side_sign * half_z
		var inward := Vector2(0.0, -side_sign)
		_add_segment(segments, Vector2(-half_x + corner_gap, z), Vector2(-side_gap, z), inward)
		_add_segment(segments, Vector2(side_gap, z), Vector2(half_x - corner_gap, z), inward)
	for end_sign in [-1.0, 1.0]:
		var x: float = end_sign * half_x
		var inward := Vector2(-end_sign, 0.0)
		_add_segment(segments, Vector2(x, -half_z + corner_gap), Vector2(x, half_z - corner_gap), inward)
	for definition in definitions:
		var outward: Vector2 = definition["outward"]
		var mouth_a: Vector2 = definition["mouth_a"]
		var mouth_b: Vector2 = definition["mouth_b"]
		var back_a: Vector2 = definition["back_a"]
		var back_b: Vector2 = definition["back_b"]
		_add_segment(segments, mouth_a, back_a, _jaw_inward(mouth_a, back_a, outward), true, int(definition["id"]))
		_add_segment(segments, mouth_b, back_b, _jaw_inward(mouth_b, back_b, outward), true, int(definition["id"]))
	return segments


func _build_cloth_outline(definitions: Array[Dictionary]) -> PackedVector2Array:
	var by_id: Dictionary = {}
	for definition in definitions:
		by_id[int(definition["id"])] = definition
	var outline := PackedVector2Array()
	# Follow the table perimeter counterclockwise. Each mouth edge is replaced
	# by its two jaw legs and the finite fall edge, making one slate+shelf polygon.
	_append_notch(outline, by_id[5])
	_append_notch(outline, by_id[3])
	_append_notch(outline, by_id[2])
	_append_notch(outline, by_id[4])
	_append_notch(outline, by_id[0])
	_append_notch(outline, by_id[1])
	return outline


func _append_notch(outline: PackedVector2Array, definition: Dictionary) -> void:
	_append_point(outline, definition["mouth_a"])
	_append_point(outline, definition["fall_a"])
	_append_point(outline, definition["fall_b"])
	_append_point(outline, definition["mouth_b"])


func _append_point(points: PackedVector2Array, point: Vector2) -> void:
	if points.is_empty() or points[points.size() - 1].distance_squared_to(point) > GEOMETRY_EPSILON * GEOMETRY_EPSILON:
		points.append(point)


func _pocket_volume_polygon(definition: Dictionary) -> PackedVector2Array:
	return PackedVector2Array([
		definition["mouth_a"], definition["mouth_b"],
		definition["back_b"], definition["back_a"],
	])


func _polygon_contains_inclusive(point: Vector2, polygon: PackedVector2Array, epsilon: float) -> bool:
	if Geometry2D.is_point_in_polygon(point, polygon):
		return true
	var epsilon_sq := epsilon * epsilon
	for index in range(polygon.size()):
		var a := polygon[index]
		var b := polygon[(index + 1) % polygon.size()]
		if Geometry2D.get_closest_point_to_segment(point, a, b).distance_squared_to(point) <= epsilon_sq:
			return true
	return false


func _jaw_inward(a: Vector2, b: Vector2, outward: Vector2) -> Vector2:
	var direction := (b - a).normalized()
	var inward := Vector2(direction.y, -direction.x)
	if inward.dot(outward) > 0.0:
		inward = -inward
	return inward


func _add_segment(
	segments: Array[Dictionary],
	a: Vector2,
	b: Vector2,
	inward: Vector2,
	jaw: bool = false,
	pocket_id: int = -1
) -> void:
	if a.distance_squared_to(b) > 1.0e-8:
		segments.append({"a": a, "b": b, "inward": inward, "jaw": jaw, "pocket_id": pocket_id})


func _corner_id(x_sign: float, z_sign: float) -> int:
	if x_sign < 0.0:
		return 0 if z_sign > 0.0 else 1
	return 2 if z_sign > 0.0 else 3
