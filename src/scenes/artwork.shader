shader_type canvas_item;

uniform bool is_disc = true;
uniform float hole_size = 0.1;
uniform sampler2D image;
uniform vec4 mod_color : hint_color = vec4(1.0);

void fragment() {
	float a = 0.01;
	vec4 color = texture(image, UV) * mod_color;
	float dist = length(2.0 * UV - vec2(1.0));
	if (is_disc && dist < hole_size + a)
		color.a = clamp((dist - hole_size) / a, 0.0, 1.0);
	if (is_disc && dist > 1.0 - a)
		color.a = clamp((1.0 - dist) / a, 0.0, 1.0);
	COLOR = color;
}