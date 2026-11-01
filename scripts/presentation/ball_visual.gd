extends Node3D
class_name BallVisual

const BALL_SHADER := preload("res://assets/shaders/ball_surface.gdshader")
var _shadow: MeshInstance3D

func configure(number: int) -> void:
	var sphere := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = BallState.RADIUS
	mesh.height = BallState.RADIUS * 2.0
	mesh.radial_segments = 48
	mesh.rings = 32
	sphere.mesh = mesh
	# Start with the number caps toward the overhead camera; physical rotation remains unchanged.
	sphere.rotation.x = -PI * 0.5
	var material := ShaderMaterial.new()
	material.shader = BALL_SHADER
	material.set_shader_parameter("ball_base", _ball_color(number))
	material.set_shader_parameter("striped", number >= 9)
	material.set_shader_parameter("numbered", number > 0)
	if number > 0:
		material.set_shader_parameter("number_texture", _number_texture(number))
	sphere.material_override = material
	add_child(sphere)
	_shadow = MeshInstance3D.new()
	var shadow_mesh := PlaneMesh.new()
	shadow_mesh.size = Vector2.ONE * BallState.RADIUS * 3.4
	_shadow.mesh = shadow_mesh
	var shadow_shader := Shader.new()
	shadow_shader.code = "shader_type spatial; render_mode unshaded, blend_mix, depth_draw_never, cull_disabled; void fragment(){float d=length(UV-vec2(0.5))*2.0; ALBEDO=vec3(0.005,0.012,0.009); ALPHA=pow(max(0.0,1.0-d),2.0)*0.48;}"
	var shadow_material := ShaderMaterial.new()
	shadow_material.shader = shadow_shader
	_shadow.material_override = shadow_material
	_shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_shadow)
	_shadow.top_level = true

func sync_from(state: BallState) -> void:
	position = Vector3(state.position.x, state.height, state.position.y)
	quaternion = state.orientation
	visible = state.phase != BallState.Phase.POCKETED and state.height > -0.08
	_shadow.global_position = Vector3(state.position.x, 0.0002, state.position.y)
	_shadow.visible = visible and state.is_on_table()
	_shadow.scale = Vector3.ONE * clampf(1.0 + (state.height - BallState.RADIUS) * 2.0, 1.0, 1.6)

func _ball_color(number: int) -> Color:
	var colors: Array[Color] = [Color("f3eee0"), Color("efb719"), Color("174ea4"), Color("ba2527"), Color("633591"), Color("e76b17"), Color("176b43"), Color("701d30"), Color("121718")]
	return colors[number if number <= 8 else number - 8]

func _number_texture(number: int) -> Texture2D:
	return load("res://assets/markings/ball-%02d.png" % number) as Texture2D
