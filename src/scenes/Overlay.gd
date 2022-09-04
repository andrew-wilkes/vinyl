extends ColorRect

var dynamic_font

func _ready():
	dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://assets/fonts/NotoSansUI_Regular.ttf")
	dynamic_font.size = 28


func _draw():
	draw_circle_arc_poly(Vector2(100, 150), 40, 0, 90, Color.aquamarine)
	var advance = draw_char(dynamic_font, Vector2(100, 250), "A", "")
	draw_set_transform(Vector2(100 + advance, 250), PI / 2.0, Vector2(1, 1))
	advance = draw_char(dynamic_font, Vector2.ZERO , "b", "")


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)
