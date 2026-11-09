extends Node3D
class_name TablePresentation

signal stroke_contact

const BallVisual = preload("res://scripts/presentation/ball_visual.gd")

var _table: TableSpec
var _camera: Camera3D
var _ball_nodes: Dictionary = {}
var _aim_mesh: MeshInstance3D
var _aim_immediate: ImmediateMesh
var _aim_material: StandardMaterial3D
var _ghost_ball: MeshInstance3D
var _cue_root: Node3D
var _cue_body: MeshInstance3D
var _cue_tip: MeshInstance3D
var _pocket_rings: Array[MeshInstance3D] = []
var _camera_tween: Tween
var _pocket_labels: Array[Label3D] = []
var _stroke_distance := 0.05
var _cue_delivery_visible := false
var _stroke_tween: Tween
var _stroke_origin := Vector3.ZERO
var _play_area := Rect2()
var _fit_area := Rect2()
var _fit_viewport := Vector2.ZERO
var _fit_transform := Transform3D()
var _view_zoom := 1.0
var _fit_zoom := -1.0
var _display_prediction: Dictionary = {}
var _aim_geometry: Array = []
var _guide_projection: Array = []


func _process(_delta: float) -> void:
	_fit_camera()
	if _guide_projection != _guide_projection_state():
		if not _display_prediction.is_empty(): set_outgoing_guide(_display_prediction)
		elif not _aim_geometry.is_empty(): _draw_aim_geometry()

func _guide_projection_state() -> Array:
	return [_camera.global_transform, _camera.size, _camera.h_offset, _camera.v_offset, get_viewport().get_visible_rect().size]


func set_play_area(area: Rect2) -> void:
	_play_area = area
	_fit_camera()


func _fit_camera() -> void:
	if _camera == null or _table == null or _play_area.size.x <= 0.0 or _play_area.size.y <= 0.0:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var transform := _camera.global_transform
	if _fit_area == _play_area and _fit_viewport == viewport_size and _fit_transform == transform and _fit_zoom == _view_zoom:
		return
	var area := _play_area.intersection(Rect2(Vector2.ZERO, viewport_size)).grow(-12.0)
	if area.size.x <= 0.0 or area.size.y <= 0.0: return
	var inverse := transform.affine_inverse()
	var low := Vector2(INF, INF)
	var high := Vector2(-INF, -INF)
	# Include the rails, wells, apron and feet, so both views fit the same table.
	for x_sign in [-1.0, 1.0]:
		for z_sign in [-1.0, 1.0]:
			for height in [-0.79, 0.10]:
				var point: Vector3 = inverse * Vector3(x_sign * (_table.half_size.x + 0.18), height, z_sign * (_table.half_size.y + 0.18))
				low = low.min(Vector2(point.x, point.y))
				high = high.max(Vector2(point.x, point.y))
	var extent := high - low
	var scale := minf(area.size.x / extent.x, area.size.y / extent.y) / _view_zoom
	var center := (low + high) * 0.5
	_camera.size = viewport_size.y / scale
	_camera.h_offset = center.x - (area.get_center().x - viewport_size.x * 0.5) / scale
	_camera.v_offset = center.y + (area.get_center().y - viewport_size.y * 0.5) / scale
	_fit_area = _play_area
	_fit_viewport = viewport_size
	_fit_transform = transform
	_fit_zoom = _view_zoom


func build(table: TableSpec) -> void:
	_table = table
	_build_room()
	_build_table()
	_build_lighting()
	_build_camera()
	_build_aim_and_cue()


func camera() -> Camera3D:
	return _camera


func project_mouse_to_table(mouse_position: Vector2, table_y: float) -> Vector2:
	var ray_origin := _camera.project_ray_origin(mouse_position)
	var ray_direction := _camera.project_ray_normal(mouse_position)
	if absf(ray_direction.y) < 1.0e-6:
		return Vector2.ZERO
	var distance := (table_y - ray_origin.y) / ray_direction.y
	if distance < 0.0:
		return Vector2.ZERO
	var point := ray_origin + ray_direction * distance
	return Vector2(point.x, point.z)


func sync_balls(balls: Array) -> void:
	for state in balls:
		if not _ball_nodes.has(state.id):
			var visual: BallVisual = BallVisual.new()
			visual.configure(state.number)
			add_child(visual)
			_ball_nodes[state.id] = visual
		var visual_node: BallVisual = _ball_nodes[state.id]
		visual_node.sync_from(state)


func set_aim(balls: Array, direction: Vector2, cue_ball: BallState, power: float, visible: bool, tip_offset: Vector2 = Vector2.ZERO, launch_direction: Vector2 = Vector2.ZERO) -> void:
	_display_prediction = {}
	_aim_geometry = []
	_aim_immediate.clear_surfaces()
	var ghost_material := _ghost_ball.material_override as StandardMaterial3D
	ghost_material.albedo_color = Color(0.93, 0.88, 0.74, 0.24)
	_cue_root.visible = _cue_delivery_visible or (visible and cue_ball != null and cue_ball.is_on_table())
	_ghost_ball.visible = false
	if not visible or cue_ball == null or not cue_ball.is_on_table() or direction.length_squared() < 0.9:
		_aim_mesh.visible = false
		return
	_aim_mesh.visible = true
	var start := Vector3(cue_ball.position.x, BallState.RADIUS + 0.002, cue_ball.position.y)
	var guide_direction := launch_direction.normalized() if launch_direction.length_squared() > 1.0e-10 else direction
	var object_hit := _first_ball_hit(balls, cue_ball, guide_direction)
	var rail_distance := _first_rail_distance(cue_ball.position, guide_direction)
	var has_object_hit := not object_hit.is_empty() and float(object_hit["distance"]) < rail_distance
	var guide_distance := rail_distance
	if has_object_hit:
		guide_distance = minf(guide_distance, float(object_hit["distance"]))
	var guide_end := start + Vector3(guide_direction.x, 0.0, guide_direction.y) * guide_distance
	_aim_geometry = [Vector2(start.x, start.z), Vector2(guide_end.x, guide_end.z), has_object_hit]
	_draw_aim_geometry()
	_update_cue(Vector3(cue_ball.position.x, cue_ball.height, cue_ball.position.y), direction, power, tip_offset)

func _draw_aim_geometry() -> void:
	_guide_projection = _guide_projection_state()
	_aim_immediate.clear_surfaces()
	_aim_immediate.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _aim_material)
	_add_guide_segment(_aim_geometry[0], _aim_geometry[1], Color("eee5cf"))
	if _aim_geometry[2]: _add_contact_ring(_aim_geometry[1])
	_aim_immediate.surface_end()
	_aim_mesh.mesh = _aim_immediate


# Called only with the current completed replay; a fresh set_aim clears all paths.
func set_outgoing_guide(prediction: Dictionary) -> void:
	if not prediction.has("contact"): return
	_display_prediction = prediction
	_guide_projection = _guide_projection_state()
	_aim_immediate.clear_surfaces()
	_aim_immediate.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _aim_material)
	_add_guide_path(prediction.incoming, Color("aeb5b0"), true)
	_add_contact_ring(prediction.contact)
	_add_guide_path(prediction.cue_path, Color("fff2ce"), false)
	_add_guide_path(prediction.object_path, Color("8cdce3"), true)
	_add_guide_arrow(prediction.cue_path, Color("fff2ce"))
	_add_guide_arrow(prediction.object_path, Color("8cdce3"))
	_aim_immediate.surface_end()

func _add_guide_path(points: PackedVector2Array, color: Color, dashed: bool) -> void:
	# Tick sampling is retained for physics; a distance based dash separates paths.
	var distance := 0.0
	for index in range(1, points.size()):
		var length := points[index].distance_to(points[index - 1])
		if not dashed or int(distance / 0.025) % 2 == 0:
			_add_guide_segment(points[index - 1], points[index], color)
		distance += length

func _add_guide_arrow(points: PackedVector2Array, color: Color) -> void:
	if points.size() < 2 or points[0].distance_to(points[-1]) < 0.015: return
	var end := points[-1]
	var direction := (end - points[maxi(0, points.size() - 4)]).normalized()
	_add_guide_segment(end, end - direction.rotated(0.48) * 0.014, color)
	_add_guide_segment(end, end - direction.rotated(-0.48) * 0.014, color)

func _add_guide_segment(first: Vector2, second: Vector2, color: Color) -> void:
	if first.distance_squared_to(second) < 1.0e-12: return
	# Screen-space ribbons keep a fine 1.5 logical-pixel line plus a dark edge.
	# Projection on the guide plane works in both cameras and after resize.
	var height := BallState.RADIUS + 0.003
	var a := _camera.unproject_position(Vector3(first.x, height, first.y))
	var b := _camera.unproject_position(Vector3(second.x, height, second.y))
	var normal := Vector2(-(b - a).y, (b - a).x).normalized()
	for layer in range(2):
		var width := 1.0 if layer == 0 else 0.75
		_aim_immediate.surface_set_color(Color("25322f") if layer == 0 else color)
		var corners := [project_mouse_to_table(a + normal * width, height), project_mouse_to_table(a - normal * width, height), project_mouse_to_table(b + normal * width, height), project_mouse_to_table(b - normal * width, height)]
		for index in [0, 1, 2, 2, 1, 3]:
			_aim_immediate.surface_add_vertex(Vector3(corners[index].x, height, corners[index].y))

func _add_contact_ring(at: Vector2) -> void:
	for index in range(48):
		var first := at + Vector2.from_angle(TAU * index / 48.0) * BallState.RADIUS
		var second := at + Vector2.from_angle(TAU * (index + 1) / 48.0) * BallState.RADIUS
		_add_guide_segment(first, second, Color("fff2ce"))


func set_placement_preview(position: Vector2, valid: bool) -> void:
	_ghost_ball.position = Vector3(position.x, BallState.RADIUS, position.y)
	var material := _ghost_ball.material_override as StandardMaterial3D
	material.albedo_color = Color(0.8, 1.0, 0.85, 0.65) if valid else Color(1.0, 0.35, 0.25, 0.65)
	_ghost_ball.visible = true


func _build_room() -> void:
	var floor := MeshInstance3D.new()
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(12.0, 12.0)
	floor.mesh = floor_mesh
	floor.position = Vector3(0.0, -0.78, 0.0)
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("#111a18")
	floor_material.roughness = 0.72
	floor_material.metallic = 0.08
	floor.material_override = floor_material
	add_child(floor)
	_add_box("Back wall", Vector3(9.5, 3.5, 0.16), Vector3(0.0, 0.95, -3.55), _mat("#1b2724", 0.87))
	_add_box("Left wall", Vector3(0.16, 3.5, 7.2), Vector3(-4.5, 0.95, 0.0), _mat("#182320", 0.9))
	_add_box("Right wall", Vector3(0.16, 3.5, 7.2), Vector3(4.5, 0.95, 0.0), _mat("#182320", 0.9))
	_add_box("Back brass rail", Vector3(9.45, 0.035, 0.035), Vector3(0.0, -0.62, -3.43), _mat("#8b6942", 0.34, 0.65))


func _build_table() -> void:
	var half_x := _table.half_size.x
	var half_z := _table.half_size.y
	for x_sign in [-1.0, 1.0]:
		for z_sign in [-1.0, 1.0]:
			var leg := MeshInstance3D.new()
			var leg_mesh := CylinderMesh.new()
			leg_mesh.top_radius = 0.072
			leg_mesh.bottom_radius = 0.105
			leg_mesh.height = 0.66
			leg_mesh.radial_segments = 24
			leg.mesh = leg_mesh
			leg.position = Vector3(x_sign * (half_x - 0.16), -0.43, z_sign * (half_z - 0.15))
			leg.material_override = _wood("#2c211a")
			add_child(leg)
			var foot := MeshInstance3D.new()
			var foot_mesh := CylinderMesh.new()
			foot_mesh.top_radius = 0.13
			foot_mesh.bottom_radius = 0.13
			foot_mesh.height = 0.045
			foot_mesh.radial_segments = 24
			foot.mesh = foot_mesh
			foot.position = Vector3(leg.position.x, -0.755, leg.position.z)
			foot.material_override = _mat("#866443", 0.27, 0.54)
			add_child(foot)
	# The slate perimeter includes each pocket shelf. There is no full plane behind
	# the openings: visible support and physical support use the same vertices.
	var outline := _table.cloth_outline()
	var slate := MeshInstance3D.new()
	slate.mesh = _outline_mesh(outline, 0.0, -0.07, true, false)
	slate.material_override = _mat("#26332c", 0.9)
	add_child(slate)
	# Apron sides leave the actual wells unobstructed from above.
	for side in [-1.0, 1.0]:
		_add_box("Long apron", Vector3(half_x * 2.0 + .22, .18, .055), Vector3(0,-.13,side*(half_z+.095)), _wood("#38281f"))
		_add_box("End apron", Vector3(.055,.18,half_z*2.0+.14), Vector3(side*(half_x+.095),-.13,0), _wood("#38281f"))
	var cloth := MeshInstance3D.new()
	cloth.mesh = _outline_mesh(outline, 0.0, 0.0, false)
	var cloth_material := ShaderMaterial.new()
	cloth_material.shader = load("res://assets/shaders/cloth_surface.gdshader")
	cloth.material_override = cloth_material
	add_child(cloth)
	_build_pockets()
	_build_rails()
	_build_table_markings()
	_build_pocket_markers()


func _build_pockets() -> void:
	for pocket in _table.pocket_definitions():
		var opening: PackedVector2Array = pocket["opening"]
		var well := MeshInstance3D.new()
		well.name = "PocketWell%d" % pocket["id"]
		well.mesh = _pocket_liner_mesh(pocket)
		var lining := _mat("#211b16", 0.94)
		lining.cull_mode = BaseMaterial3D.CULL_DISABLED
		well.material_override = lining
		add_child(well)
		var bottom := MeshInstance3D.new()
		bottom.mesh = _outline_mesh(opening, -0.18, -0.18, false)
		bottom.material_override = _mat("#050706", 1.0)
		add_child(bottom)


func _pocket_liner_mesh(pocket: Dictionary) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var points := PackedVector2Array([pocket.fall_a,pocket.back_a,pocket.back_b,pocket.fall_b])
	for i in range(3):
		var a := points[i]
		var b := points[i+1]
		# Match the three physical liner walls; the front slate edge stays open.
		_mesh_triangle(surface,Vector3(a.x,2.0*BallState.RADIUS,a.y),Vector3(b.x,2.0*BallState.RADIUS,b.y),Vector3(b.x,-.18,b.y))
		_mesh_triangle(surface,Vector3(a.x,2.0*BallState.RADIUS,a.y),Vector3(b.x,-.18,b.y),Vector3(a.x,-.18,a.y))
	surface.generate_normals()
	return surface.commit()


func _outline_mesh(outline: PackedVector2Array, top: float, bottom: float, sides: bool, cap: bool = true) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var triangles := Geometry2D.triangulate_polygon(outline)
	if cap:
		for i in range(0, triangles.size(), 3):
			var a := outline[triangles[i]]
			var b := outline[triangles[i+1]]
			var c := outline[triangles[i+2]]
			_mesh_triangle(surface, Vector3(a.x,top,a.y), Vector3(b.x,top,b.y), Vector3(c.x,top,c.y))
	if sides:
		for i in range(outline.size()):
			var a := outline[i]
			var b := outline[(i+1)%outline.size()]
			_mesh_triangle(surface,Vector3(a.x,top,a.y),Vector3(b.x,top,b.y),Vector3(b.x,bottom,b.y))
			_mesh_triangle(surface,Vector3(a.x,top,a.y),Vector3(b.x,bottom,b.y),Vector3(a.x,bottom,a.y))
	surface.generate_normals()
	return surface.commit()


func _cushion_mesh(a: Vector2, b: Vector2, inward: Vector2) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var section := [Vector2(0.0,_table.cushion_nose_height),Vector2(-.029,.051),Vector2(-.029,.007)]
	for i in range(3):
		var next := (i+1)%3
		var p: Vector2 = section[i]
		var q: Vector2 = section[next]
		var pa := Vector3(a.x+inward.x*p.x,p.y,a.y+inward.y*p.x)
		var pb := Vector3(b.x+inward.x*p.x,p.y,b.y+inward.y*p.x)
		var qa := Vector3(a.x+inward.x*q.x,q.y,a.y+inward.y*q.x)
		var qb := Vector3(b.x+inward.x*q.x,q.y,b.y+inward.y*q.x)
		_mesh_triangle(surface,pa,pb,qb)
		_mesh_triangle(surface,pa,qb,qa)
	for endpoint in [a,b]:
		var points: Array[Vector3] = []
		for p in section: points.append(Vector3(endpoint.x+inward.x*p.x,p.y,endpoint.y+inward.y*p.x))
		_mesh_triangle(surface,points[0],points[2],points[1])
	surface.generate_normals()
	return surface.commit()


func _build_rails() -> void:
	for segment in _table.rail_segments():
		var a: Vector2 = segment["a"]
		var b: Vector2 = segment["b"]
		var jaw: bool = segment["jaw"]
		var inward: Vector2 = segment["inward"]
		var midpoint := (a + b) * 0.5
		var tangent := b - a
		var rail_depth := 0.04 if jaw else 0.12
		var rail := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(tangent.length(), 0.092, rail_depth)
		rail.mesh = _beveled_box(mesh.size, 0.006)
		rail.position = Vector3(midpoint.x - inward.x * rail_depth * 0.5, 0.048, midpoint.y - inward.y * rail_depth * 0.5)
		rail.rotation.y = atan2(-tangent.y, tangent.x)
		rail.material_override = _wood("#503928")
		add_child(rail)
		var cushion := MeshInstance3D.new()
		cushion.mesh = _cushion_mesh(a,b,inward)
		var rubber := _mat("#174e40", 0.88)
		rubber.cull_mode = BaseMaterial3D.CULL_DISABLED
		cushion.material_override = rubber
		add_child(cushion)
		if not jaw:
			var inlay := MeshInstance3D.new()
			var inlay_mesh := BoxMesh.new()
			inlay_mesh.size = Vector3(tangent.length() * 0.93, 0.004, 0.007)
			inlay.mesh = inlay_mesh
			inlay.position = Vector3(rail.position.x, 0.096, rail.position.z)
			inlay.rotation.y = rail.rotation.y
			inlay.material_override = _mat("#b39361", 0.25, 0.62)
			add_child(inlay)


func _build_table_markings() -> void:
	for x in [-0.635, 0.0, 0.635]:
		var mark := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.006
		mesh.bottom_radius = 0.006
		mesh.height = 0.0015
		mesh.radial_segments = 20
		mark.mesh = mesh
		mark.position = Vector3(x, 0.002, 0.0)
		mark.material_override = _mat("#d0c19b", 0.84)
		add_child(mark)
	var head_string := MeshInstance3D.new()
	var line := BoxMesh.new()
	line.size = Vector3(0.001, 0.0015, _table.half_size.y * 1.8)
	head_string.mesh = line
	head_string.position = Vector3(-0.635, 0.002, 0.0)
	head_string.material_override = _mat("#48664d", 0.95)
	add_child(head_string)


func _build_lighting() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#101a17")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#84978b")
	environment.ambient_light_energy = 0.34
	var reflection_sky := Sky.new()
	var reflection_material := ShaderMaterial.new()
	reflection_material.shader = preload("res://assets/shaders/room_reflections.gdshader")
	reflection_sky.sky_material = reflection_material
	environment.sky = reflection_sky
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.adjustment_enabled = true
	environment.adjustment_saturation = 0.92
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color("#d8c9a9")
	sun.light_energy = 0.52
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-53.0, -24.0, 0.0)
	add_child(sun)
	for index in range(3):
		var x := float(index - 1) * 0.78
		var pendant := MeshInstance3D.new()
		var shade := CylinderMesh.new()
		shade.top_radius = 0.048
		shade.bottom_radius = 0.16
		shade.height = 0.075
		shade.radial_segments = 32
		pendant.visible = false
		pendant.mesh = shade
		pendant.position = Vector3(x, 2.04, 0.0)
		pendant.material_override = _mat("#242b27", 0.2, 0.55)
		add_child(pendant)
		var trim := MeshInstance3D.new()
		var trim_mesh := CylinderMesh.new()
		trim_mesh.top_radius = 0.05
		trim_mesh.bottom_radius = 0.055
		trim_mesh.height = 0.009
		trim_mesh.radial_segments = 32
		trim.visible = false
		trim.mesh = trim_mesh
		trim.position = Vector3(x, 2.0, 0.0)
		trim.material_override = _mat("#b18b52", 0.26, 0.68)
		add_child(trim)
		var light := SpotLight3D.new()
		light.position = Vector3(x, 1.96, 0.0)
		light.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		light.light_color = Color("#f6e2bd")
		light.light_energy = 1.35
		light.spot_range = 3.2
		light.spot_angle = 46.0
		light.shadow_enabled = index == 1
		add_child(light)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	_camera.size = 2.15
	_camera.h_offset = 0.28
	_camera.position = Vector3(0.0, 3.8, 3.0)
	_camera.current = true
	add_child(_camera)
	_camera.make_current()
	_camera.look_at(Vector3(0.0, 0.02, 0.0), Vector3.UP)


func _build_aim_and_cue() -> void:
	_aim_immediate = ImmediateMesh.new()
	_aim_mesh = MeshInstance3D.new()
	_aim_mesh.mesh = _aim_immediate
	_aim_material = StandardMaterial3D.new()
	_aim_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_aim_material.vertex_color_use_as_albedo = true
	_aim_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_aim_material.no_depth_test = true
	add_child(_aim_mesh)
	var ghost_sphere := SphereMesh.new()
	ghost_sphere.radius = BallState.RADIUS
	ghost_sphere.height = BallState.RADIUS * 2.0
	ghost_sphere.radial_segments = 24
	ghost_sphere.rings = 12
	_ghost_ball = MeshInstance3D.new()
	_ghost_ball.mesh = ghost_sphere
	var ghost_material := StandardMaterial3D.new()
	ghost_material.albedo_color = Color(0.93, 0.88, 0.74, 0.24)
	ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ghost_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ghost_material.no_depth_test = true
	_ghost_ball.material_override = ghost_material
	_ghost_ball.visible = false
	add_child(_ghost_ball)
	_cue_root = Node3D.new()
	add_child(_cue_root)
	_cue_body = MeshInstance3D.new()
	var cue_mesh := CylinderMesh.new()
	cue_mesh.top_radius = 0.0065
	cue_mesh.bottom_radius = 0.012
	cue_mesh.height = 0.90
	cue_mesh.radial_segments = 12
	_cue_body.mesh = cue_mesh
	_cue_body.material_override = _wood("#b99360")
	_cue_root.add_child(_cue_body)
	_cue_tip = MeshInstance3D.new()
	var tip_mesh := CylinderMesh.new()
	tip_mesh.top_radius = 0.0064
	tip_mesh.bottom_radius = 0.0045
	tip_mesh.height = 0.008
	tip_mesh.radial_segments = 12
	_cue_tip.mesh = tip_mesh
	_cue_tip.position.y = 0.466
	_cue_tip.material_override = _mat("#487d84", 0.82)
	_cue_root.add_child(_cue_tip)
	var ferrule := MeshInstance3D.new()
	var ferrule_mesh := CylinderMesh.new()
	ferrule_mesh.top_radius = 0.0064
	ferrule_mesh.bottom_radius = 0.0064
	ferrule_mesh.height = 0.022
	ferrule_mesh.radial_segments = 20
	ferrule.mesh = ferrule_mesh
	ferrule.position.y = 0.451
	ferrule.material_override = _mat("#e4dcc5",0.3)
	_cue_root.add_child(ferrule)
	var wrap := MeshInstance3D.new()
	var wrap_mesh := CylinderMesh.new()
	wrap_mesh.top_radius = 0.0113
	wrap_mesh.bottom_radius = 0.0122
	wrap_mesh.height = 0.18
	wrap_mesh.radial_segments = 20
	wrap.mesh = wrap_mesh
	wrap.position.y = -0.32
	wrap.material_override = _mat("#17221e",0.68)
	_cue_root.add_child(wrap)


func _first_ball_hit(balls: Array, cue_ball: BallState, direction: Vector2) -> Dictionary:
	var nearest_distance := INF
	var nearest_ball: BallState
	for item in balls:
		var ball: BallState = item
		if ball.id == cue_ball.id or not ball.is_on_table():
			continue
		var offset: Vector2 = ball.position - cue_ball.position
		var along: float = offset.dot(direction)
		if along <= 0.0:
			continue
		var perpendicular_sq: float = offset.length_squared() - along * along
		var radius_sum := BallState.RADIUS * 2.0
		if perpendicular_sq < radius_sum * radius_sum:
			var hit_distance: float = along - sqrt(radius_sum * radius_sum - perpendicular_sq)
			if hit_distance < nearest_distance:
				nearest_distance = maxf(0.0, hit_distance)
				nearest_ball = ball
	if nearest_ball == null:
		return {}
	return {"distance": nearest_distance, "ball": nearest_ball}


func _first_rail_distance(position: Vector2, direction: Vector2) -> float:
	var distance := INF
	var nose_offset := _table.cushion_nose_height-BallState.RADIUS
	var radius := sqrt(maxf(0.0,BallState.RADIUS*BallState.RADIUS-nose_offset*nose_offset))
	for segment in _table.rail_segments():
		var a: Vector2 = segment.a
		var b: Vector2 = segment.b
		var normal: Vector2 = segment.inward
		var approach := direction.dot(normal)
		if approach < -1.0e-8:
			var t := (radius-(position-a).dot(normal))/approach
			var hit := position+direction*t
			var along := (hit-a).dot((b-a).normalized())
			if t >= 0.0 and along >= 0.0 and along <= a.distance_to(b): distance = minf(distance,t)
		# Rounded endpoint contacts use the same finite segment footprint as the solver.
		for endpoint in [a,b]:
			var offset: Vector2 = position-endpoint
			var linear := 2.0*offset.dot(direction)
			var discriminant := linear*linear-4.0*(offset.length_squared()-radius*radius)
			if discriminant < 0.0: continue
			var t := (-linear-sqrt(discriminant))*.5
			if t >= 0.0 and (position+direction*t-endpoint).dot(normal) >= -.001: distance = minf(distance,t)
	# An open pocket has a slate fall edge rather than an invisible rectangular rail.
	for pocket in _table.pocket_definitions():
		var outward: Vector2 = pocket.outward
		var approach := direction.dot(outward)
		if approach <= 1.0e-8: continue
		var a: Vector2 = pocket.fall_a
		var b: Vector2 = pocket.fall_b
		var t := (a-position).dot(outward)/approach
		var along := (position+direction*t-a).dot((b-a).normalized())
		if t >= 0.0 and along >= 0.0 and along <= a.distance_to(b): distance = minf(distance,t)
	return distance if is_finite(distance) else 0.45


func _update_cue(cue_position: Vector3, direction: Vector2, power: float, tip_offset: Vector2 = Vector2.ZERO) -> void:
	var aim := Vector3(direction.x, 0.0, direction.y).normalized()
	var lateral := Vector3(-aim.z, 0.0, aim.x)
	var tip := tip_offset.limit_length(CueStrikeModel.MAX_TIP_OFFSET)
	# Match CueStrikeModel's contact arm, including the selected tip position.
	var contact := cue_position - aim * BallState.RADIUS * sqrt(1.0 - tip.length_squared())
	contact += (lateral * tip.x + Vector3.UP * tip.y) * BallState.RADIUS
	_stroke_distance = 0.008 + clampf(power, 0.0, 1.0) * 0.075
	# The tip front is local y=.470, not the shaft's y=.450 endpoint.
	_cue_root.position = contact - aim * (0.470 + _stroke_distance)
	var x_axis := Vector3.UP.cross(aim).normalized()
	var z_axis := x_axis.cross(aim).normalized()
	_cue_root.basis = Basis(x_axis, aim, z_axis).orthonormalized()


func _add_box(label: String, size: Vector3, at: Vector3, material: Material) -> void:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = _beveled_box(size, 0.006)
	instance.position = at
	instance.material_override = material
	instance.name = label
	add_child(instance)


func _mat(color: String, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color)
	material.roughness = roughness
	material.metallic = metallic
	return material


func pocket_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for pocket in _table.pocket_definitions(): positions.append(pocket.mouth_center)
	return positions


func _build_pocket_markers() -> void:
	var positions := pocket_positions()
	for index in range(positions.size()):
		var ring := MeshInstance3D.new()
		var mesh := TorusMesh.new()
		mesh.inner_radius = 0.077
		mesh.outer_radius = 0.082
		mesh.rings = 32
		mesh.ring_segments = 8
		ring.mesh = mesh
		ring.position = Vector3(positions[index].x, 0.012, positions[index].y)
		var material := _mat("#efc880", 0.3, 0.4)
		material.emission_enabled = true
		material.emission = Color("#96713c")
		ring.material_override = material
		ring.visible = false
		add_child(ring)
		_pocket_rings.append(ring)
		var label := Label3D.new()
		label.text = str(index + 1)
		label.font_size = 26
		label.pixel_size = 0.0012
		label.outline_size = 4
		label.modulate = Color("#f3d9a5")
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.position = Vector3(positions[index].x, 0.10, positions[index].y)
		label.visible = false
		add_child(label)
		_pocket_labels.append(label)
	for z_sign in [-1.0, 1.0]:
		for slot in [-3, -2, -1, 1, 2, 3]:
			_add_sight(Vector3(float(slot) * _table.half_size.x / 4.0, 0.099, z_sign * (_table.half_size.y + 0.065)))
	for x_sign in [-1.0, 1.0]:
		for slot in [-1, 0, 1]:
			_add_sight(Vector3(x_sign * (_table.half_size.x + 0.065), 0.099, float(slot) * _table.half_size.y / 2.0))


func _add_sight(at: Vector3) -> void:
	var sight := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.008
	mesh.bottom_radius = 0.008
	mesh.height = 0.002
	mesh.radial_segments = 4
	sight.mesh = mesh
	sight.position = at
	sight.material_override = _mat("#d5c6a6", 0.3, 0.25)
	add_child(sight)


func set_called_pocket(id: int) -> void:
	for index in range(_pocket_rings.size()):
		_pocket_rings[index].visible = index == id
		_pocket_labels[index].visible = id >= 0


func set_overhead(overhead: bool) -> void:
	if is_instance_valid(_camera_tween):
		_camera_tween.kill()
	var at := Vector3(0.0, 5.0, 0.001) if overhead else Vector3(0.0, 3.8, 3.0)
	var up := Vector3.FORWARD if overhead else Vector3.UP
	var target := Transform3D(Basis.IDENTITY, at).looking_at(Vector3(0.0, 0.02, 0.0), up)
	_camera_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_camera_tween.tween_property(_camera, "transform", target, 0.45)


func zoom(amount: float) -> void:
	_view_zoom = clampf(_view_zoom + amount, 1.0, 1.5)
	_fit_camera()


func _wood(color: String) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = "shader_type spatial; uniform vec4 wood_color:source_color; varying vec3 p; void vertex(){p=VERTEX;} void fragment(){float g=sin(p.z*280.0+sin(p.x*3.0)*1.8+sin(p.x*8.0)*0.3); float fine=sin(p.z*830.0+sin(p.x*9.0)); ALBEDO=wood_color.rgb*(0.94+g*0.045+fine*0.012); ROUGHNESS=0.43; METALLIC=0.04; CLEARCOAT=0.18; CLEARCOAT_ROUGHNESS=0.38;}"
	material.shader = shader
	material.set_shader_parameter("wood_color", Color(color))
	return material


func play_stroke(on_contact: Callable) -> void:
	cancel_stroke()
	_cue_delivery_visible = true
	_stroke_origin = _cue_root.position
	var axis := _cue_root.basis.y.normalized()
	var contact_position := _stroke_origin + axis * _stroke_distance
	_stroke_tween = create_tween()
	# A brief controlled backswing, then accelerating delivery to the exact tip contact.
	_stroke_tween.tween_property(_cue_root, "position", _stroke_origin - axis * 0.008, 0.025).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_stroke_tween.tween_property(_cue_root, "position", contact_position, 0.075).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_stroke_tween.tween_callback(func():
		on_contact.call()
		stroke_contact.emit()
	)
	# Keep the contact pose visible across a rendered frame instead of hiding it
	# in the callback before the player can see it.
	_stroke_tween.tween_interval(0.025)
	_stroke_tween.tween_callback(func():
		_cue_delivery_visible = false
		_cue_root.hide()
		_stroke_tween = null
	)


func cancel_stroke() -> void:
	_cue_delivery_visible = false
	if is_instance_valid(_stroke_tween):
		_stroke_tween.kill()
	_stroke_tween = null


func _beveled_box(size: Vector3, bevel: float) -> ArrayMesh:
	var x := size.x * 0.5
	var z := size.z * 0.5
	var h := size.y * 0.5
	var b := minf(bevel, minf(x, minf(z, h)) * 0.6)
	var outline: Array[Vector2] = [Vector2(-x+b,-z),Vector2(x-b,-z),Vector2(x,-z+b),Vector2(x,z-b),Vector2(x-b,z),Vector2(-x+b,z),Vector2(-x,z-b),Vector2(-x,-z+b)]
	var top: Array[Vector3] = []
	var belt: Array[Vector3] = []
	var bottom: Array[Vector3] = []
	for p in outline:
		bottom.append(Vector3(p.x,-h,p.y))
		belt.append(Vector3(p.x,h-b,p.y))
		top.append(Vector3(clampf(p.x,-x+b,x-b),h,clampf(p.y,-z+b,z-b)))
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	for i in range(8):
		var j := (i+1)%8
		_mesh_triangle(surface, Vector3(0,h,0), top[j], top[i])
		_mesh_triangle(surface, top[i], top[j], belt[j])
		_mesh_triangle(surface, top[i], belt[j], belt[i])
		_mesh_triangle(surface, belt[i], belt[j], bottom[j])
		_mesh_triangle(surface, belt[i], bottom[j], bottom[i])
		_mesh_triangle(surface, Vector3(0,-h,0),bottom[i],bottom[j])
	surface.generate_normals()
	return surface.commit()


func _mesh_triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	for p in [a,b,c]:
		surface.set_uv(Vector2(p.x,p.z))
		surface.add_vertex(p)
