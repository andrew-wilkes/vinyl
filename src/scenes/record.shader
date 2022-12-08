shader_type spatial;

uniform float num_rings = 32;
// Spiral is drawn between rmax and rmin
uniform float rmax = 0.95;
uniform float rmin = 0.4;
uniform float label_radius = 0.3;
uniform float scale = 1.0;
uniform sampler2D label_a;
uniform sampler2D label_b;
// Input data for controlling the pitch of the spiral over tracks and gaps
uniform sampler2D radius_mod_a;
uniform sampler2D radius_mod_b;
uniform float inner_smoothing = 30.0;
uniform float outer_smoothing = 10.0;
uniform vec2 dot_position = vec2(0.0);
uniform float dot_radius = 1.5;
uniform vec4 dot_color: hint_color = vec4(1.0, 0.0, 0.0, 0.0);
uniform float alphav = 0.0;
uniform float blur = 0.1;
uniform float width = 0.1;

const float PI = 3.14159265358979323846;

void vertex() {
	VERTEX *= scale;
}

void fragment() {
	float lr = label_radius / scale;
	float scaled_rmin = rmin / scale;
	if (UV.y < 0.5) {
		ALBEDO = vec3(0.0);
	} else {
		float thickness = 0.5;
		vec4 col = COLOR;
		// Get point in bottom 2 square areas
		vec2 pt = vec2(fract(UV.x * 2.0), clamp(UV.y - 0.5, 0.0, 0.5) * 2.0);
		pt = 2.0 * (pt - vec2(0.5)); // 0,0 .. +/-1,+/-1
		float ang = (atan(sign(UV.x - 0.5) * pt.y / pt.x) / PI * 2.0 + 1.0) / 4.0; // 0 .. 0.5
		if (pt.x < 0.0) ang += 0.5;
		float dr = 0.5 / num_rings;
		float pr = length(pt);
		float radius_mod = 1.0;
		if (pr > scaled_rmin) {
			float pos = 1.0 - (pr - scaled_rmin) / (rmax - scaled_rmin);
			if (UV.x < 0.5) {
				radius_mod = texture(radius_mod_a, vec2(pos, 0.0)).r;
			} else {
				radius_mod = texture(radius_mod_b, vec2(pos, 0.0)).r;
			}
		}
		float radius = pr + dr * ang + sin(ang * 1000.0) * sin(ang * 3.0 * 500.0) * 0.001; // radius of the point on a spiral
		//if (ang < 0.25) radius += dr / 2.0;
		if (pr < lr) {
			// Display label
			vec2 p = pt / lr / 2.0;
			if (UV.x < 0.5)
				ALBEDO = texture(label_a, p + vec2(0.5)).rgb;
			else {
				p.x = -p.x;
				ALBEDO = texture(label_b, p + vec2(0.5)).rgb;
			}
			// Smooth edge
			ALBEDO *= clamp((lr - pr) * inner_smoothing, 0.0, 1.0);
		} else {
			vec3 track_color = vec3(0.02);
			float circles = fract(radius / dr); // 0 .. 1
			if (pr < rmax && radius > scaled_rmin) {
				ALBEDO = (smoothstep(circles - blur,circles,width) - smoothstep(circles,circles + blur,width)) * track_color * radius_mod;
			} else {
				// Outside
				ALBEDO = vec3(0.0);
			}
		}
		if (length(dot_position) > 0.2 && length(vec2(dot_position.x, dot_position.y * sign(0.5 - UV.x)) - pt) < dot_radius / 100.0) {
			if (radius_mod > 0.8)
				ALBEDO = dot_color.rgb;
			else
				ALBEDO = vec3(0.0, 1.0, 0.0);
		}
	}
	ALPHA *= alphav;
}