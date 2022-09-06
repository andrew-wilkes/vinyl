extends ViewportContainer

var blank
var overlay
var dynamic_font
var size
var base_size
var hole_size = 0.1 setget set_hole_size

export var is_disc = true
export(Color) var mod_color = Color.white
export(Texture) var image

func _ready():
	overlay = $Viewport/C/Overlay
	blank = $Viewport/Blank
	overlay.connect("draw", self, "draw")
	dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://assets/fonts/NotoSansUI_Regular.ttf")
	dynamic_font.size = 28
	blank.material.set_shader_param("is_disc", is_disc)
	blank.material.set_shader_param("image", image)
	blank.material.set_shader_param("mod_color", mod_color)


func set_hole_size(n):
	blank.material.set_shader_param("hole_size", n)


func _on_ImageView_sort_children():
	size = min(rect_size.x, rect_size.y)
	if base_size == null: base_size = size
	# Allow size to be reduced
	$Viewport.size = Vector2.ZERO
	overlay.rect_scale = Vector2(size, size) / base_size
	#overlay.update()
	$Viewport/Blank.rect_size = Vector2(size, size)
	# Avoid flicker
	$Timer.start()


func _on_Timer_timeout():
	$Viewport.size = Vector2(size, size)


func _on_Snap_pressed():
	var img = $Viewport.get_viewport().get_texture().get_data()
	img.flip_y()
	# Allow for enlarged viewport
	img.resize(base_size, base_size)
	img.save_png("res://temp.png")


func draw():
	draw_circle_arc_poly(Vector2(100, 150), 40, 0, 90, Color.aquamarine)
	var advance = overlay.draw_char(dynamic_font, Vector2(100, 250), "A", "")
	overlay.draw_set_transform(Vector2(100 + advance, 250), PI / 2.0, Vector2(1, 1))
	advance = overlay.draw_char(dynamic_font, Vector2.ZERO , "b", "")


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
