shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 ball_base : source_color = vec4(0.95, 0.93, 0.86, 1.0);
uniform vec4 stripe_base : source_color = vec4(0.96, 0.94, 0.88, 1.0);
uniform bool striped = false;

void fragment() {
	float band = step(0.405, UV.y) * (1.0 - step(0.595, UV.y));
	vec3 base = ball_base.rgb;
	if (striped) {
		base = mix(ball_base.rgb, stripe_base.rgb, band);
	}
	ALBEDO = base;
	ROUGHNESS = 0.19;
	METALLIC = 0.0;
}
