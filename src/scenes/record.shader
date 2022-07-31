shader_type canvas_item;

uniform float num_rings = 64;
uniform float rmax = 1.0;
uniform float rmin = 0.4;
uniform float label_radius = 0.3;
uniform sampler2D label;

const float PI = 3.14159265358979323846;

void fragment() {
	float thickness = 0.5;
	vec4 col = COLOR;
	vec2 pt = 2.0 * (UV - vec2(0.5));
	float ang = atan(-pt.y / pt.x); // +PI .. -PI
	float dr = 0.5 / num_rings;
	float pr = length(pt);
	float radius = pr + dr * (0.5 + ang / PI);
	if (pt.x < 0.0) radius += dr;
	float pos_in_band = fract(radius * num_rings); // 0 .. 1
	if (pos_in_band > thickness && radius < rmax && radius > rmin)
		COLOR.rgb = vec3(0.1);
	else {
		if (pr < rmax) {
			if (pr < label_radius) {
				// Display label
				COLOR = texture(label, pt / label_radius / 2.0 + vec2(0.5));
				// Smooth edge
				COLOR.rbg *= clamp((label_radius - pr) * 200.0, 0.0, 1.0);
			} else
				COLOR.rgb = vec3(0.0);
		} else {
			// Outside
			COLOR.rgb = vec3(0.0);
			// Smooth edge
			COLOR.a = clamp(1.0 - (pr - rmax) * 200.0, 0.0, 1.0);
		}
	}
}