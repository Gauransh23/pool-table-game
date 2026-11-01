shader_type sky;
// Original, static studio-light reflection field. It supplies broad highlights
// without importing a photographic environment or changing the room background.
void sky() {
	vec3 room = mix(vec3(0.018,0.024,0.021),vec3(0.075,0.085,0.075),clamp(EYEDIR.y,0.0,1.0));
	if (EYEDIR.y > 0.0) {
		vec2 ceiling = EYEDIR.xz / max(EYEDIR.y,0.001);
		vec2 edge = abs(ceiling - vec2(0.12,-0.10)) - vec2(0.65,0.15);
		float softbox = 1.0 - smoothstep(-0.025,0.035,max(edge.x,edge.y));
		room += vec3(2.0,1.92,1.72) * softbox;
	}
	COLOR = room;
}
