extends Node3D
class_name TablePresentation

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


func set_aim(balls: Array, direction: Vector2, cue_ball: BallState, power: float, visible: bool) -> void:
	_aim_immediate.clear_surfaces()
	_cue_root.visible = visible and cue_ball.is_on_table()
	_ghost_ball.visible = false
	if not visible or not cue_ball.is_on_table() or direction.length_squared() < 0.9:
		_aim_mesh.visible = false
		return
	_aim_mesh.visible = true
	var start := Vector3(cue_ball.position.x, BallState.RADIUS + 0.002, cue_ball.position.y)
	var object_hit := _first_ball_hit(balls, cue_ball, direction)
	var rail_distance := _first_rail_distance(cue_ball.position, direction)
	var has_object_hit := not object_hit.is_empty() and float(object_hit["distance"]) < rail_distance
	var guide_distance := rail_distance
	if has_object_hit:
		guide_distance = minf(guide_distance, float(object_hit["distance"]))
	var guide_end := start + Vector3(direction.x, 0.0, direction.y) * guide_distance
	_aim_immediate.surface_begin(Mesh.PRIMITIVE_LINES, _aim_material)
	_aim_immediate.surface_set_color(Color("#eee5cf"))
	_aim_immediate.surface_add_vertex(start)
	_aim_immediate.surface_add_vertex(guide_end)
	if has_object_hit:
		var object_ball: BallState = object_hit["ball"]
		var object_direction := Vector3(direction.x, 0.0, direction.y)
		var object_start := Vector3(object_ball.position.x, BallState.RADIUS + 0.002, object_ball.position.y) + object_direction * BallState.RADIUS
		_aim_immediate.surface_set_color(Color("#77c1b2"))
		_aim_immediate.surface_add_vertex(object_start)
		_aim_immediate.surface_add_vertex(object_start + object_direction * 0.45)
		_ghost_ball.position = guide_end
		_ghost_ball.visible = true
	_aim_immediate.surface_end()
	_aim_mesh.mesh = _aim_immediate
	_update_cue(start, direction, power)


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
			leg.material_override = _mat("#2c211a", 0.31, 0.12)
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
	_add_box("Slate and apron", Vector3(half_x * 2.0 + 0.22, 0.19, half_z * 2.0 + 0.22), Vector3(0.0, -0.105, 0.0), _mat("#38281f", 0.32, 0.2))
	_add_box("Apron brass reveal", Vector3(half_x * 2.0 + 0.225, 0.016, half_z * 2.0 + 0.225), Vector3(0.0, -0.018, 0.0), _mat("#986f42", 0.3, 0.62))
	_add_box("Cloth bed", Vector3(half_x * 2.0 + 0.15, 0.07, half_z * 2.0 + 0.15), Vector3(0.0, -0.034, 0.0), _mat("#35251d", 0.36, 0.17))
	var cloth := MeshInstance3D.new()
	var cloth_mesh := PlaneMesh.new()
	cloth_mesh.size = Vector2(half_x * 2.0, half_z * 2.0)
	cloth.mesh = cloth_mesh
	cloth.position.y = 0.002
	var cloth_material := ShaderMaterial.new()
	cloth_material.shader = load("res://assets/shaders/cloth_surface.gdshader")
	cloth.material_override = cloth_material
	add_child(cloth)
	_build_pockets()
	_build_rails()
	_build_table_markings()


func _build_pockets() -> void:
	var pocket_material := _mat("#080c0b", 0.25, 0.12)
	var corner_radius := 0.083
	for x_sign in [-1.0, 1.0]:
		for z_sign in [-1.0, 1.0]:
			_add_pocket_disk(
				Vector3(x_sign * (_table.half_size.x - 0.028), 0.002, z_sign * (_table.half_size.y - 0.028)),
				corner_radius,
				pocket_material
			)
	for z_sign in [-1.0, 1.0]:
		_add_pocket_disk(Vector3(0.0, 0.002, z_sign * (_table.half_size.y - 0.018)), 0.088, pocket_material)


func _add_pocket_disk(at: Vector3, radius: float, material: Material) -> void:
	var pocket := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius * 0.96
	mesh.height = 0.006
	mesh.radial_segments = 40
	pocket.mesh = mesh
	pocket.position = at
	pocket.material_override = material
	add_child(pocket)


func _build_rails() -> void:
	for segment in _table.rail_segments():
		var a: Vector2 = segment["a"]
		var b: Vector2 = segment["b"]
		var jaw: bool = segment["jaw"]
		var inward: Vector2 = segment["inward"]
		var midpoint := (a + b) * 0.5
		var tangent := b - a
		var rail_depth := 0.12 if not jaw else 0.058
		var rail := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(tangent.length(), 0.092 if not jaw else 0.075, rail_depth)
		rail.mesh = mesh
		rail.position = Vector3(midpoint.x - inward.x * rail_depth * 0.5, 0.048, midpoint.y - inward.y * rail_depth * 0.5)
		rail.rotation.y = atan2(-tangent.y, tangent.x)
		rail.material_override = _mat("#402c21", 0.28, 0.22)
		add_child(rail)
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
	for x in [-0.82, 0.0, 0.82]:
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
	line.size = Vector3(0.002, 0.0015, _table.half_size.y * 1.8)
	head_string.mesh = line
	head_string.position = Vector3(-0.82, 0.002, 0.0)
	head_string.material_override = _mat("#c8b890", 0.89)
	add_child(head_string)


func _build_lighting() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#101a17")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#84978b")
	environment.ambient_light_energy = 0.42
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.adjustment_enabled = true
	environment.adjustment_saturation = 0.92
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.light_color = Color("#d8c9a9")
	sun.light_energy = 0.72
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
		trim.mesh = trim_mesh
		trim.position = Vector3(x, 2.0, 0.0)
		trim.material_override = _mat("#b18b52", 0.26, 0.68)
		add_child(trim)
		var light := SpotLight3D.new()
		light.position = Vector3(x, 1.96, 0.0)
		light.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		light.light_color = Color("#f6e2bd")
		light.light_energy = 2.15
		light.spot_range = 3.2
		light.spot_angle = 46.0
		light.shadow_enabled = index == 1
		add_child(light)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = 3.25
	_camera.position = Vector3(0.0, 3.45, 3.35)
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
	cue_mesh.height = 0.58
	cue_mesh.radial_segments = 12
	_cue_body.mesh = cue_mesh
	_cue_body.material_override = _mat("#8a6341", 0.36, 0.17)
	_cue_root.add_child(_cue_body)
	_cue_tip = MeshInstance3D.new()
	var tip_mesh := CylinderMesh.new()
	tip_mesh.top_radius = 0.0064
	tip_mesh.bottom_radius = 0.0045
	tip_mesh.height = 0.038
	tip_mesh.radial_segments = 12
	_cue_tip.mesh = tip_mesh
	_cue_tip.position.y = 0.29
	_cue_tip.material_override = _mat("#d2b881", 0.48, 0.08)
	_cue_root.add_child(_cue_tip)


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
				nearest_distance = maxf(0.035, hit_distance)
				nearest_ball = ball
	if nearest_ball == null:
		return {}
	return {"distance": nearest_distance, "ball": nearest_ball}


func _first_rail_distance(position: Vector2, direction: Vector2) -> float:
	var distance := INF
	if direction.x > 1.0e-7:
		distance = minf(distance, (_table.half_size.x - BallState.RADIUS - position.x) / direction.x)
	elif direction.x < -1.0e-7:
		distance = minf(distance, (-_table.half_size.x + BallState.RADIUS - position.x) / direction.x)
	if direction.y > 1.0e-7:
		distance = minf(distance, (_table.half_size.y - BallState.RADIUS - position.y) / direction.y)
	elif direction.y < -1.0e-7:
		distance = minf(distance, (-_table.half_size.y + BallState.RADIUS - position.y) / direction.y)
	return maxf(0.04, distance)


func _update_cue(cue_position: Vector3, direction: Vector2, power: float) -> void:
	var aim := Vector3(direction.x, 0.0, direction.y).normalized()
	var elevation := deg_to_rad(10.0)
	var cue_axis := Vector3(aim.x * cos(elevation), -sin(elevation), aim.z * cos(elevation)).normalized()
	var retract := 0.025 + clampf(power, 0.0, 1.0) * 0.075
	var cue_end := cue_position - aim * retract + Vector3.UP * 0.008
	var cue_center := cue_end - cue_axis * 0.29
	_cue_root.position = cue_center
	var x_axis := Vector3.UP.cross(cue_axis).normalized()
	var z_axis := x_axis.cross(cue_axis).normalized()
	_cue_root.basis = Basis(x_axis, cue_axis, z_axis).orthonormalized()


func _add_box(label: String, size: Vector3, at: Vector3, material: Material) -> void:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
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
