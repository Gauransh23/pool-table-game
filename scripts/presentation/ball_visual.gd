extends Node3D
class_name BallVisual

const BALL_SHADER := preload("res://assets/shaders/ball_surface.gdshader")

var _number: int = 0


func configure(number: int) -> void:
	_number = number
	var sphere := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = BallState.RADIUS
	sphere_mesh.height = BallState.RADIUS * 2.0
	sphere_mesh.radial_segments = 40
	sphere_mesh.rings = 24
	sphere.mesh = sphere_mesh
	sphere.material_override = _make_ball_material(number)
	add_child(sphere)
	if number > 0:
		_add_number_mark(number)


func sync_from(state: BallState) -> void:
	position = Vector3(state.position.x, state.height, state.position.y)
	quaternion = state.orientation
	visible = state.phase != BallState.Phase.POCKETED and state.height > -0.08


func _make_ball_material(number: int) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = BALL_SHADER
	material.set_shader_parameter("ball_base", _ball_color(number))
	material.set_shader_parameter("stripe_base", Color("#f5f0df"))
	material.set_shader_parameter("striped", number >= 9)
	return material


func _ball_color(number: int) -> Color:
	var colors: Array[Color] = [
		Color("#f3eee0"), Color("#f2c230"), Color("#2869b2"), Color("#be4038"),
		Color("#6a4c91"), Color("#e67832"), Color("#428255"), Color("#713c42"),
		Color("#17191a"), Color("#f2c230"), Color("#2869b2"), Color("#be4038"),
		Color("#6a4c91"), Color("#e67832"), Color("#428255"), Color("#713c42"),
	]
	return colors[clampi(number, 0, colors.size() - 1)]


func _add_number_mark(number: int) -> void:
	var plate := MeshInstance3D.new()
	var plate_mesh := SphereMesh.new()
	plate_mesh.radius = BallState.RADIUS * 0.245
	plate_mesh.height = BallState.RADIUS * 0.07
	plate_mesh.radial_segments = 24
	plate_mesh.rings = 8
	plate.mesh = plate_mesh
	var plate_material := StandardMaterial3D.new()
	plate_material.albedo_color = Color("#f5f0df")
	plate_material.roughness = 0.58
	plate.material_override = plate_material
	plate.position = Vector3(0.0, BallState.RADIUS * 0.96, 0.0)
	add_child(plate)
	var label := Label3D.new()
	label.text = str(number)
	label.font_size = 18
	label.pixel_size = 0.00055
	label.modulate = Color("#151718")
	label.outline_size = 0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.rotation_degrees.x = -90.0
	label.position = Vector3(0.0, BallState.RADIUS * 1.1, 0.0)
	add_child(label)
