shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
uniform vec4 ball_base : source_color = vec4(0.95, 0.93, 0.86, 1.0);
uniform bool striped = false;
uniform bool numbered = false;
uniform sampler2D number_texture : source_color, filter_linear_mipmap;
varying vec3 ball_point;
void vertex() { ball_point = VERTEX / 0.028575; }
void fragment() {
	vec3 p = normalize(ball_point);
	vec3 base = ball_base.rgb;
	if (striped) { base = mix(vec3(0.94, 0.91, 0.83), base, 1.0 - smoothstep(0.57, 0.60, abs(p.y))); }
	if (numbered && abs(p.z) > 0.83) {
		vec2 cap = vec2(p.x * sign(p.z), -p.y);
		float mask = 1.0 - smoothstep(0.45, 0.47, length(cap));
		base = mix(base, texture(number_texture, cap / 0.94 + vec2(0.5)).rgb, mask);
	}
	ALBEDO = base;
	ROUGHNESS = 0.23;
	METALLIC = 0.0;
	CLEARCOAT = 0.22;
	CLEARCOAT_ROUGHNESS = 0.20;
}
