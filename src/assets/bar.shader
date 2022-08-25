shader_type canvas_item;

uniform vec4 gap_color : hint_color;
uniform vec4 ok_color : hint_color;
uniform vec4 warn_color : hint_color;
uniform vec4 spare_color : hint_color;
uniform sampler2D data;

void fragment() {
	float x = texture(data, UV).r;
	if (x > 0.9) {
		COLOR = warn_color;
	} else {
		if (x > 0.5)
			COLOR = ok_color;
		else {
			if (x > 0.3)
				COLOR = spare_color;
			else
				COLOR = gap_color;
		}
	}
}