shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 cloth_tint : source_color = vec4(0.055, 0.235, 0.175, 1.0);

void fragment() {
	float cross_weave = sin(UV.x * 810.0) * sin(UV.y * 770.0);
	float nap = sin(UV.x * 96.0 + sin(UV.y * 37.0)) * sin(UV.y * 105.0);
	float variation = 0.975 + cross_weave * 0.012 + nap * 0.018;
	ALBEDO = cloth_tint.rgb * variation;
	ROUGHNESS = 0.92;
	METALLIC = 0.0;
}
