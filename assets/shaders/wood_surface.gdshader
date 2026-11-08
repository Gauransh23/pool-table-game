shader_type spatial;
uniform vec4 wood_color : source_color;
varying vec3 p;
void vertex() { p = VERTEX; }
void fragment() {
 float phase = p.z * 280.0 + sin(p.x * 3.0) * 1.8;
 float fine_phase = p.z * 830.0 + sin(p.x * 9.0);
 float grain = sin(phase) * (1.0 - smoothstep(0.6,1.6,fwidth(phase)));
 float fine = sin(fine_phase) * (1.0 - smoothstep(0.6,1.6,fwidth(fine_phase)));
 ALBEDO = wood_color.rgb * (0.94 + grain * 0.045 + fine * 0.012);
 ROUGHNESS = 0.62;
 METALLIC = 0.0;
 SPECULAR = 0.22;
 CLEARCOAT = 0.05;
 CLEARCOAT_ROUGHNESS = 0.38;
}
