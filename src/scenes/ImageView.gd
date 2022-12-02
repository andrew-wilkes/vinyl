extends ViewportContainer

var blank
var overlay
var size
var base_size
var scale
var hole_size = 0.1 setget set_hole_size
var arc_width = 4.0
var elements

export var is_disc = true setget set_canvas_type
export(Color) var mod_color = Color.white setget set_mod_color
export(Texture) var image setget set_image

func _ready():
	overlay = $Viewport/C/Overlay
	blank = $Viewport/Blank
	overlay.connect("draw", self, "draw")


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
	if elements == null: return
	#var _chr_width = overlay.draw_char(dynamic_font, Vector2(-10, -10), "A", "")
	var b2 = base_size / 2
	for el in elements:
		match el.type:
			ArtElement.AB:
				var pos = Vector2(min(el.position.x, 0.95), max(el.position.y, 0.05)) * base_size
				var ang = el.rotation + 0.5
				overlay.draw_set_transform(pos, ang * PI * 2.0, Vector2(1, 1))
				overlay.draw_string(el.font, Vector2.ZERO, el.text, el.color)
			ArtElement.ABROT:
				if el.text.length() == 0:
					continue
				var xr = el.position.x * b2
				var yr = el.position.y * b2
				var ang = el.rotation + 0.25
				var astep = 0.0
				if  el.text.length() > 1:
					ang -= el.length / 2.0
					astep = el.length / (el.text.length() - 1)
				for chr in el.text:
					var th1 = ang * PI * 2.0
					var th2 = th1 + PI / 2.0
					var pos = Vector2(b2 + xr * cos(th1), b2 + yr * sin(th1))
					overlay.draw_set_transform(pos, th2, Vector2(1, 1))
					var _advance = overlay.draw_char(el.font, Vector2.ZERO, chr, "", el.color)
					ang = ang + astep
			ArtElement.ARC:
				var ang = el.rotation + 0.5
				overlay.draw_set_transform(el.position * base_size, ang * PI, Vector2(1, 1))
				overlay.draw_arc(Vector2.ZERO, b2 * el.length, ang * PI * 2.0, (ang + el.size) * PI * 2.0, el.size * el.length * 16 + 32, el.color, arc_width)
			ArtElement.CIRC:
				overlay.draw_circle(el.position * base_size, b2 * max(el.length, 0.1), el.color)
			ArtElement.BOX:
				var ang = el.rotation + 0.5
				overlay.draw_set_transform(el.position * base_size, ang * PI * 2.0, Vector2(1, 1))
				overlay.draw_rect(Rect2(Vector2.ZERO, Vector2(el.length, el.length) * b2), el.color, false, el.size * 32)
			ArtElement.DOT:
				arc_width = el.size * 32 # Use for arc also
				overlay.draw_arc(el.position * base_size, b2 * el.length, -PI, PI, el.length * 16 + 32, el.color, arc_width)
			ArtElement.LINE:
				var ang = el.rotation + 0.5
				overlay.draw_set_transform(el.position * base_size, ang * PI * 2.0, Vector2(1, 1))
				overlay.draw_line(Vector2.ZERO, Vector2(el.length * base_size, 0), el.color, el.size * 32)
			ArtElement.SQR:
				var ang = el.rotation + 0.5
				overlay.draw_set_transform(el.position * base_size, ang * PI * 2.0, Vector2(1, 1))
				overlay.draw_rect(Rect2(Vector2.ZERO, Vector2(el.length, el.length) * b2), el.color, true)


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
