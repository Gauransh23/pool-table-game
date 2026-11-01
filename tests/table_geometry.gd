extends SceneTree

const TableSpec = preload("res://scripts/sim/table_spec.gd")

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var table := TableSpec.new()
	_check(table.has_method("pocket_definitions"), "TableSpec exposes pocket definitions")
	_check(table.has_method("cloth_outline"), "TableSpec exposes one cloth outline")
	_check(table.has_method("is_supported"), "TableSpec exposes support membership")
	if not table.has_method("pocket_definitions") or not table.has_method("cloth_outline") or not table.has_method("is_supported"):
		quit(1)
		return
	var definitions: Array = table.call("pocket_definitions")
	_check(definitions.size() == 6, "exactly six pocket definitions exist")
	_test_definitions(table, definitions)
	_test_finite_jaws(table, definitions)
	_test_cloth_outline_and_support(table, definitions)
	_test_pocket_volume(table, definitions)
	_test_geometry_cache_invalidation(table)
	if failures == 0:
		print("PASS: shared pocket geometry definitions, support, volume, and finite jaws")
		quit(0)
	else:
		printerr("FAIL: %d shared geometry assertions" % failures)
		quit(1)


func _check(condition: bool, description: String) -> void:
	print("%s: %s" % ["PASS" if condition else "FAIL", description])
	if not condition:
		failures += 1


func _test_definitions(table: TableSpec, definitions: Array) -> void:
	var seen_ids: Dictionary = {}
	for definition in definitions:
		var id: int = definition.get("id", -1)
		seen_ids[id] = true
		var mouth_a: Vector2 = definition.get("mouth_a", Vector2.ZERO)
		var mouth_b: Vector2 = definition.get("mouth_b", Vector2.ZERO)
		var outward: Vector2 = definition.get("outward", Vector2.ZERO)
		var center: Vector2 = definition.get("mouth_center", Vector2.ZERO)
		_check(definition.has("fall_a") and definition.has("fall_b") and definition.has("back_a") and definition.has("back_b"),
			"pocket %d defines fall and back endpoints" % id)
		_check(definition.get("opening", PackedVector2Array()) is PackedVector2Array and definition["opening"].size() == 4,
			"pocket %d has a four-corner opening polygon" % id)
		_check(definition.get("support_edges", []).size() == 3, "pocket %d exposes the three shelf boundary edges" % id)
		_check(is_equal_approx(outward.length(), 1.0), "pocket %d outward vector is unit length" % id)
		_check(mouth_a.distance_to(mouth_b) > 0.0 and center.distance_to((mouth_a + mouth_b) * 0.5) < 1.0e-6,
			"pocket %d has the defined mouth center and endpoints" % id)
		var expected_mouth := table.corner_mouth if id < 4 else table.side_mouth
		_check(absf(mouth_a.distance_to(mouth_b) - expected_mouth) < 1.0e-6,
			"pocket %d keeps its configured mouth width" % id)
		var shelf_depth := float(definition.get("shelf_depth", -1.0))
		var measured_shelf_depth := ((Vector2(definition.get("fall_a", Vector2.ZERO)) + Vector2(definition.get("fall_b", Vector2.ZERO))) * 0.5 - center).dot(outward)
		_check(absf(measured_shelf_depth - shelf_depth) < 1.0e-6, "pocket %d fall edge is at its configured shelf depth" % id)
		var back_depth := ((Vector2(definition.get("back_a", Vector2.ZERO)) + Vector2(definition.get("back_b", Vector2.ZERO))) * 0.5 - center).dot(outward)
		_check(absf(back_depth - table.pocket_depth) < 1.0e-6, "pocket %d finite back edge uses pocket_depth" % id)
		var tangent := Vector2(-outward.y, outward.x)
		var jaw_a: Vector2 = (Vector2(definition["back_a"]) - mouth_a).normalized()
		var expected_deviation := deg_to_rad(7.0 if id < 4 else 14.0)
		_check(absf(jaw_a.dot(outward) - cos(expected_deviation)) < 1.0e-6 and
			absf(jaw_a.dot(tangent) - sin(expected_deviation)) < 1.0e-6,
			"pocket %d jaw direction follows its symmetric WPA cut angle" % id)
	_check(seen_ids.size() == 6 and seen_ids.has(0) and seen_ids.has(1) and seen_ids.has(2) and seen_ids.has(3) and seen_ids.has(4) and seen_ids.has(5),
		"pocket ids cover four corners and two sides")
	_test_corner_mirrors(definitions)
	_test_side_mirror(definitions)


func _test_corner_mirrors(definitions: Array) -> void:
	var by_id := _index_by_id(definitions)
	for pair in [[0, 2], [1, 3]]:
		var left: Dictionary = by_id[pair[0]]
		var right: Dictionary = by_id[pair[1]]
		_check(_mirror_x(left["mouth_a"]).distance_to(right["mouth_b"]) < 1.0e-6 and
			_mirror_x(left["mouth_b"]).distance_to(right["mouth_a"]) < 1.0e-6,
			"corner pocket pair %d/%d mirrors across table length" % [pair[0], pair[1]])
		_check(_mirror_x(left["fall_a"]).distance_to(right["fall_b"]) < 1.0e-6 and
			_mirror_x(left["back_a"]).distance_to(right["back_b"]) < 1.0e-6,
			"corner pocket pair %d/%d mirrors jaw endpoints" % [pair[0], pair[1]])


func _test_side_mirror(definitions: Array) -> void:
	var by_id := _index_by_id(definitions)
	var upper: Dictionary = by_id[4]
	var lower: Dictionary = by_id[5]
	_check(_mirror_y(upper["mouth_a"]).distance_to(lower["mouth_b"]) < 1.0e-6 and
		_mirror_y(upper["mouth_b"]).distance_to(lower["mouth_a"]) < 1.0e-6,
		"side pocket pair mirrors across table width")
	_check(_mirror_y(upper["back_a"]).distance_to(lower["back_b"]) < 1.0e-6,
		"side pocket jaw endpoints mirror across table width")


func _test_finite_jaws(table: TableSpec, definitions: Array) -> void:
	var segments: Array = table.rail_segments()
	var jaw_counts: Dictionary = {}
	for segment in segments:
		if not segment.get("jaw", false):
			continue
		var id: int = segment.get("pocket_id", -1)
		jaw_counts[id] = int(jaw_counts.get(id, 0)) + 1
		var a: Vector2 = segment["a"]
		var b: Vector2 = segment["b"]
		_check(a.distance_to(b) > 0.0, "jaw %d has finite nonzero length" % id)
	for definition in definitions:
		var id: int = definition["id"]
		_check(int(jaw_counts.get(id, 0)) == 2, "pocket %d generates two finite jaw segments" % id)
		var backs_apart: float = Vector2(definition["back_a"]).distance_to(definition["back_b"])
		_check(backs_apart > 0.01, "pocket %d jaws do not converge to a throat point" % id)
	_check(jaw_counts.size() == 6, "rail segment list contains jaws for every pocket")


func _test_cloth_outline_and_support(table: TableSpec, definitions: Array) -> void:
	var outline: PackedVector2Array = table.call("cloth_outline")
	_check(outline.size() >= 18, "cloth outline includes all six shelf extensions")
	_check(not Geometry2D.is_polygon_clockwise(outline), "cloth outline has a consistent counterclockwise winding")
	_check(Geometry2D.triangulate_polygon(outline).size() == (outline.size() - 2) * 3, "cloth outline triangulates as one simple polygon")
	_check(table.is_supported(Vector2.ZERO), "center of slate is supported")
	_check(table.is_supported(Vector2(table.half_size.x - 0.001, 0.0)), "ordinary near-rail cloth remains supported")
	_check(not table.is_supported(Vector2(-table.half_size.x + 0.001, table.half_size.y - 0.001)),
		"corner pocket opening does not gain a triangle of false slate support")
	for definition in definitions:
		var id: int = definition["id"]
		var center: Vector2 = definition["mouth_center"]
		var outward: Vector2 = definition["outward"]
		var shelf_depth: float = definition["shelf_depth"]
		var fall_center: Vector2 = (Vector2(definition["fall_a"]) + Vector2(definition["fall_b"])) * 0.5
		_check(table.is_supported(center + outward * shelf_depth), "pocket %d fall edge is support-inclusive" % id)
		_check(table.is_supported(center + outward * (shelf_depth * 0.5)), "pocket %d shelf center remains supported" % id)
		_check(not table.is_supported(fall_center + outward * 0.0002), "pocket %d is unsupported just beyond its fall edge" % id)


func _test_pocket_volume(table: TableSpec, definitions: Array) -> void:
	for definition in definitions:
		var id: int = definition["id"]
		var center: Vector2 = definition["mouth_center"]
		var outward: Vector2 = definition["outward"]
		var shelf_depth: float = definition["shelf_depth"]
		var middle_depth := (shelf_depth + table.pocket_depth) * 0.5
		_check(table.pocket_at(center) == id, "pocket %d owns its mouth center" % id)
		_check(table.pocket_at(center + outward * middle_depth) == id, "pocket %d owns the opening from shelf to back" % id)
		_check(not table.is_supported(center + outward * middle_depth), "pocket %d opening has no support" % id)
		_check(not table.outside_table(center + outward * middle_depth), "pocket %d volume is not classified off-table before its back" % id)
		_check(table.pocket_at(center + outward * (table.pocket_depth + 0.01)) == -1,
			"pocket %d volume ends at its finite back edge" % id)
		_check(table.outside_table(center + outward * (table.pocket_depth + 0.01)),
			"pocket %d beyond-back position is outside the table lifecycle" % id)


func _test_geometry_cache_invalidation(table: TableSpec) -> void:
	var before: Dictionary = _index_by_id(table.pocket_definitions())[0]
	var old_fall: Vector2 = before["fall_a"]
	table.corner_shelf += 0.001
	var after: Dictionary = _index_by_id(table.pocket_definitions())[0]
	_check(after["fall_a"].distance_to(old_fall) > 0.0009, "changing a shelf parameter rebuilds cached pocket definitions")
	_check(table.cloth_outline().size() == 24, "changing a shelf parameter rebuilds the shared cloth outline")
	var old_half_size := table.half_size
	table.half_size.x += 0.01
	var resized: Dictionary = _index_by_id(table.pocket_definitions())[0]
	_check(resized["mouth_center"].distance_to(after["mouth_center"]) > 0.009, "changing table dimensions rebuilds cached pocket definitions")
	table.half_size = old_half_size


func _index_by_id(definitions: Array) -> Dictionary:
	var result: Dictionary = {}
	for definition in definitions:
		result[int(definition["id"])] = definition
	return result


func _mirror_x(point: Vector2) -> Vector2:
	return Vector2(-point.x, point.y)


func _mirror_y(point: Vector2) -> Vector2:
	return Vector2(point.x, -point.y)
