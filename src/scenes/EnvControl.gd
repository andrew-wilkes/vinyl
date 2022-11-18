extends GridContainer

signal info_pressed

enum { CLEAR, PICTURE, PANORAMA }

export(PanoramaSky) var sky
export var image_idx = 0

var we: WorldEnvironment

func setup(world_env):
	we = world_env
	var img_path = g.settings.bg_images[image_idx]
	if sky == null:
		sky = PanoramaSky.new()
	if img_path:
		load_image(img_path)
	$BGColor.color = g.settings.bg_color_3d[image_idx]
	set_bg_mode()
	$c/ImageSelector.clear_filters()
	$c/ImageSelector.add_filter("*.jpg, *.png, *.exr, *.hdr ; Supported Image Files")
	resize_bg()


func _on_Picture_pressed():
	var img_path = g.settings.bg_images[image_idx]
	if img_path == null:
		$c/ImageSelector.current_dir = g.settings.last_image_dir
		$c/ImageSelector.current_file = ""
	else:
		$c/ImageSelector.current_dir = img_path.get_base_dir()
		$c/ImageSelector.current_path = img_path
	$c/ImageSelector.popup_centered()


func _on_BGColor_color_changed(color):
	g.settings.bg_color_3d[image_idx] = color.to_rgba32()
	if we.environment.background_mode == Environment.BG_COLOR:
		we.environment.background_color = color


func _on_Button_pressed():
	g.settings.bg_modes[image_idx] = wrapi(g.settings.bg_modes[image_idx] + 1, 0, 3)
	set_bg_mode()


func _on_Info_pressed():
	emit_signal("info_pressed")


func _on_ImageSelector_file_selected(path):
	g.settings.last_image_dir = path.get_base_dir()
	g.settings.bg_images[image_idx] = path
	load_image(path)


func load_image(path):
	var text = g.get_resized_texture(path)
	sky.panorama = text.texture
	we.get_child(0).texture = text.texture
	resize_bg()


func set_bg_mode():
	match g.settings.bg_modes[image_idx]:
		CLEAR:
			we.environment.background_mode = Environment.BG_COLOR
			we.environment.background_color = g.settings.bg_color_3d[image_idx]
			we.get_child(0).hide()
		PICTURE:
			we.environment.background_mode = Environment.BG_CANVAS
			we.get_child(0).show()
		PANORAMA:
			we.get_child(0).hide()
			we.environment.background_mode = Environment.BG_SKY
			if sky.panorama:
				we.environment.background_sky = sky


func resize_bg():
	var img = we.get_child(0).texture
	if img:
		var canvas_size = get_viewport().get_visible_rect().size
		var img_size = img.get_size()
		var sc = max(canvas_size.x / img_size.x, canvas_size.y / img_size.y)
		we.get_child(0).scale = Vector2(sc, sc)
