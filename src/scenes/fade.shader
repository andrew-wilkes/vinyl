shader_type canvas_item;

uniform float value;
uniform vec2 aspect;

void fragment() {
	float radius = length((UV - vec2(0.5)) * aspect);
	if (radius > value) {
		COLOR.rgb = vec3(0.0);
	} else {
		COLOR.a = 0.0;
	}
}