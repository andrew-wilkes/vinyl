shader_type spatial;

uniform float num_rings = 32;
uniform float rmax = 0.95;
uniform float rmin = 0.4;
uniform float label_radius = 0.3;
uniform sampler2D label_a;
uniform sampler2D label_b;
uniform float inner_smoothing = 30.0;
uniform float outer_smoothing = 10.0;
uniform vec2 dot_position = vec2(0.0);
uniform float dot_radius = 1.5;
uniform vec4 dot_color: hint_color = vec4(1.0, 0.0, 0.0, 0.0);
uniform float alphav = 0.0;

const float PI = 3.14159265358979323846;

void fragment() {
	if (UV.y < 0.5) {
		ALBEDO = vec3(0.0);
	} else {
		float thickness = 0.5;
		vec4 col = COLOR;
		// Get point in bottom 2 square areas
		vec2 pt = vec2(fract(UV.x * 2.0), (UV.y - 0.5) * 2.0);
		pt = 2.0 * (pt - vec2(0.5)); // 0,0 .. +/-1,+/-1
		float ang = atan(-pt.y / pt.x); // +PI .. -PI
		float dr = 0.5 / num_rings;
		float pr = length(pt);
		float radius = pr + dr * (0.5 + ang / PI); // radius of the point on a spiral
		if (pt.x < 0.0) radius += dr;
		float pos_in_band = fract(radius * num_rings); // 0 .. 1
		if (pr < label_radius) {
			// Display label
			if (UV.x < 0.5)
				ALBEDO = texture(label_a, pt / label_radius / 2.0 + vec2(0.5)).rgb;
			else
				ALBEDO = texture(label_b, pt / label_radius / 2.0 + vec2(0.5)).rgb;
			// Smooth edge
			ALBEDO *= clamp((label_radius - pr) * inner_smoothing, 0.0, 1.0);
		} else {
			if (pr < rmax) {
				if (pos_in_band > thickness && radius > rmin)
					ALBEDO.rgb = vec3(0.02);
				else {
					ALBEDO = vec3(0.0);
				}
			} else {
				// Outside
				ALBEDO = vec3(0.0);
				// Smooth edge
				ALPHA = clamp((1.0 - pr) * outer_smoothing, 0.0, 1.0);
			}
		}
		if (dot_position.x > 0.2 && length(dot_position - pt) < dot_radius / 100.0) ALBEDO = dot_color.rgb;
	}
	ALPHA *= alphav;
}