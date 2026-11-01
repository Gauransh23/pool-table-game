extends SceneTree
var failures := 0
var checks := 0
func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: " + description)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var table := TableSpec.new()
	var view := TablePresentation.new()
	view._table = table
	var mesh := view._outline_mesh(table.cloth_outline(),0,0,false)
	var arrays := mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	check(not vertices.is_empty(), "slate produces actual triangles")
	for i in range(vertices.size()):
		check(normals[i].y > .99, "slate top faces the camera instead of being culled")
		check(absf(vertices[i].y) < 1.0e-7, "rendered cloth shares physical support height")
	for i in range(0,vertices.size(),3):
		var center := (vertices[i]+vertices[i+1]+vertices[i+2])/3.0
		check(table.is_supported(Vector2(center.x,center.z)), "slate triangle does not fill a pocket opening")
	var side_guide := view._first_rail_distance(Vector2.ZERO,Vector2.DOWN)
	check(absf(side_guide-(table.half_size.y+table.side_shelf)) < .00001, "initial path ends at side-pocket slate edge, not an invisible rail")
	var offset := table.cushion_nose_height-BallState.RADIUS
	var clearance := sqrt(BallState.RADIUS*BallState.RADIUS-offset*offset)
	check(absf(view._first_rail_distance(Vector2.ZERO,Vector2.RIGHT)-(table.half_size.x-clearance)) < .00001, "initial path uses physical nose clearance on a closed rail")
	view.free()
	print("VISUAL GEOMETRY: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
