extends ViewportContainer

var blank
var overlay
var dynamic_font
var size
var base_size
var scale
var hole_size = 0.1 setget set_hole_size
var strings = []
var rotated_strings = []

export var is_disc = true setget set_canvas_type
export(Color) var mod_color = Color.white setget set_mod_color
export(Texture) var image setget set_image

func _ready():
	overlay = $Viewport/C/Overlay
	blank = $Viewport/Blank
	overlay.connect("draw", self, "draw")
	dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://assets/fonts/NotoSansUI_Regular.ttf")
	dynamic_font.use_filter = true
	dynamic_font.size = 32


func set_mod_color(color):
	if blank:
		blank.material.set_shader_param("mod_color", color)
		mod_color = color


func set_hole_size(n):
	if blank:
		blank.material.set_shader_param("hole_size", n)


func set_canvas_type(disc):
	is_disc = disc
	if blank:
		blank.material.set_shader_param("is_disc", disc)


func set_image(img):
	image = img
	if blank:
		blank.material.set_shader_param("image", image)


func _on_ImageView_sort_children():
	size = min(rect_size.x, rect_size.y)
	if base_size == null: base_size = size
	# Allow size to be reduced
	$Viewport.size = Vector2.ZERO
	overlay.rect_size = Vector2(base_size, base_size)
	scale = Vector2(size, size) / base_size
	overlay.rect_scale = scale
	overlay.update()
	$Viewport/Blank.rect_size = Vector2(size, size)
	# Avoid flicker
	$Timer.start()


func _on_Timer_timeout():
	$Viewport.size = Vector2(size, size)


func get_texture():
	var img = $Viewport.get_viewport().get_texture().get_data()
	img.flip_y()
	# Allow for enlarged viewport
	img.resize(base_size, base_size)
	return img


func draw():
	for s in strings:
		#dynamic_font.size = s.size * 32
		var pos = Vector2(min(s.position.x, 0.95), max(s.position.y, 0.05)) * base_size
		var ang = s.rotation + 0.5
		overlay.draw_set_transform(pos, ang * PI * 2.0, Vector2(1, 1))
		overlay.draw_string(dynamic_font, Vector2.ZERO, s.text, s.color)
	var b2 = base_size / 2
	for s in rotated_strings:
		if s.text.length() == 0:
			continue
		var xr = s.position.x * b2
		var yr = s.position.y * b2
		var ang = s.rotation + 0.25
		var astep = 0.0
		if  s.text.length() > 1:
			ang -= s.length / 2.0
			astep = s.length / (s.text.length() - 1)
		for chr in s.text:
			var th1 = ang * PI * 2.0
			var th2 = th1 + PI / 2.0
			var pos = Vector2(b2 + xr * cos(th1), b2 + yr * sin(th1))
			overlay.draw_set_transform(pos, th2, Vector2(1, 1))
			var _advance = overlay.draw_char(dynamic_font, Vector2.ZERO, chr, "")
			ang = ang + astep
	"""
	draw_circle_arc_poly(Vector2(100, 150), 40, 0, 90, Color.aquamarine)
	var advance = overlay.draw_char(dynamic_font, Vector2(100, 250), "A", "")
	overlay.draw_set_transform(Vector2(100 + advance, 250), PI / 2.0, Vector2(1, 1))
	advance = overlay.draw_char(dynamic_font, Vector2.ZERO , "b", "")
	"""


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	overlay.draw_polygon(points_arc, colors)


func get_pixel_pos(uv):
	return uv * base_size
