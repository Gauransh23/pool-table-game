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
var _pocket_rings: Array[MeshInstance3D] = []
var _camera_tween: Tween
var _pocket_labels: Array[Label3D] = []
var _stroke_distance := 0.05


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
	_cue_root.visible = visible and cue_ball != null and cue_ball.is_on_table()
	_ghost_ball.visible = false
	if not visible or cue_ball == null or not cue_ball.is_on_table() or direction.length_squared() < 0.9:
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
		var object_direction := (Vector3(object_ball.position.x, guide_end.y, object_ball.position.y) - guide_end).normalized()
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
	_add_box("Slate and apron", Vector3(half_x * 2.0 + 0.22, 0.19, half_z * 2.0 + 0.22), Vector3(0.0, -0.105, 0.0), _wood("#38281f"))
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
	_build_pocket_markers()


func _build_pockets() -> void:
	var pocket_material := _mat("#020403", 0.98)
	pocket_material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	var corner_radius := 0.067
	for x_sign in [-1.0, 1.0]:
		for z_sign in [-1.0, 1.0]:
			_add_pocket_disk(
				Vector3(x_sign * (_table.half_size.x - 0.028), 0.002, z_sign * (_table.half_size.y - 0.028)),
				corner_radius,
				pocket_material
			)
	for z_sign in [-1.0, 1.0]:
		_add_pocket_disk(Vector3(0.0, 0.002, z_sign * (_table.half_size.y - 0.018)), 0.072, pocket_material)


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
	var lining := MeshInstance3D.new()
	var rim := TorusMesh.new()
	rim.inner_radius = radius * 0.96
	rim.outer_radius = radius * 1.08
	rim.rings = 48
	rim.ring_segments = 12
	lining.mesh = rim
	lining.position = at + Vector3.UP * 0.005
	lining.material_override = _mat("#241c16", 0.55, 0.05)
	add_child(lining)


func _build_rails() -> void:
	for segment in _table.rail_segments():
		var a: Vector2 = segment["a"]
		var b: Vector2 = segment["b"]
		var jaw: bool = segment["jaw"]
		var inward: Vector2 = segment["inward"]
		var midpoint := (a + b) * 0.5
		var tangent := b - a
		if jaw:
			continue
		var rail_depth := 0.12
		var rail := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(tangent.length(), 0.092, rail_depth)
		rail.mesh = _beveled_box(mesh.size, 0.006)
		rail.position = Vector3(midpoint.x - inward.x * rail_depth * 0.5, 0.048, midpoint.y - inward.y * rail_depth * 0.5)
		rail.rotation.y = atan2(-tangent.y, tangent.x)
		rail.material_override = _wood("#503928")
		add_child(rail)
		var cushion := MeshInstance3D.new()
		var cushion_mesh := BoxMesh.new()
		cushion_mesh.size = Vector3(tangent.length(), 0.045, 0.029)
		cushion.mesh = _beveled_box(cushion_mesh.size,0.008)
		cushion.position = Vector3(midpoint.x - inward.x * 0.012, 0.024, midpoint.y - inward.y * 0.012)
		cushion.rotation.y = rail.rotation.y
		cushion.material_override = _mat("#174e40", 0.88)
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
	var elevation := 0.0
	var cue_axis := Vector3(aim.x * cos(elevation), -sin(elevation), aim.z * cos(elevation)).normalized()
	var retract := BallState.RADIUS + 0.025 + clampf(power, 0.0, 1.0) * 0.075
	_stroke_distance = retract - 0.020 - BallState.RADIUS + 0.003
	var cue_end := cue_position - aim * retract
	var cue_center := cue_end - cue_axis * 0.45
	_cue_root.position = cue_center
	var x_axis := Vector3.UP.cross(cue_axis).normalized()
	var z_axis := x_axis.cross(cue_axis).normalized()
	_cue_root.basis = Basis(x_axis, cue_axis, z_axis).orthonormalized()


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
	var x := _table.half_size.x - 0.028
	var z := _table.half_size.y - 0.028
	return [Vector2(-x,z), Vector2(-x,-z), Vector2(x,z), Vector2(x,-z), Vector2(0,z), Vector2(0,-z)]


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
	_camera.size = clampf(_camera.size + amount, 1.8, 3.0)


func _wood(color: String) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = "shader_type spatial; uniform vec4 wood_color:source_color; varying vec3 p; void vertex(){p=VERTEX;} void fragment(){float g=sin(p.z*280.0+sin(p.x*3.0)*1.8+sin(p.x*8.0)*0.3); float fine=sin(p.z*830.0+sin(p.x*9.0)); ALBEDO=wood_color.rgb*(0.94+g*0.045+fine*0.012); ROUGHNESS=0.43; METALLIC=0.04; CLEARCOAT=0.18; CLEARCOAT_ROUGHNESS=0.38;}"
	material.shader = shader
	material.set_shader_parameter("wood_color", Color(color))
	return material


func play_stroke() -> void:
	if not _cue_root.visible:
		return
	var axis := _cue_root.basis.y.normalized()
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(_cue_root, "position", _cue_root.position + axis * _stroke_distance, 0.10)


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
