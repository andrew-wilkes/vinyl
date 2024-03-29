extends Container

signal info_pressed
signal slider1_changed(value)

enum { CLEAR, PICTURE, PANORAMA }

export(PanoramaSky) var sky
export var image_idx = 0

const bg_modes = ["Solid background color", "Background picture", "HDRI 3D panoramic background"]

var we: WorldEnvironment

func setup(world_env):
	we = world_env
	var img_path = g.settings.bg_images[image_idx]
	if sky == null:
		sky = PanoramaSky.new()
	if img_path:
		load_image(img_path)
	$Grid/BGColor.color = g.settings.bg_color_3d[image_idx]
	set_bg_mode(g.settings.bg_modes[image_idx])
	$c/ImageSelector.clear_filters()
	$c/ImageSelector.add_filter("*.jpg, *.png, *.exr, *.hdr ; Supported Image Files")
	$VB1/VSlider1.value = g.settings.bg_brightness[image_idx]
	$VB2/VSlider2.value = g.settings.env_brightness[image_idx]
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


func _on_ModeButton_pressed():
	var bg_mode = wrapi(g.settings.bg_modes[image_idx] + 1, 0, 3)
	g.settings.bg_modes[image_idx] = bg_mode
	set_bg_mode(bg_mode)


func _on_InfoButton_pressed():
	emit_signal("info_pressed")


func _on_ImageSelector_file_selected(path):
	g.settings.last_image_dir = path.get_base_dir()
	g.settings.bg_images[image_idx] = path
	load_image(path)
	resize_bg()


func load_image(path):
	var text = g.get_resized_texture(path)
	$Path.text = text.error
	sky.panorama = text.texture
	we.get_child(0).texture = text.texture


func set_bg_mode(bg_mode):
	match bg_mode:
		CLEAR:
			we.environment.background_mode = Environment.BG_COLOR
			we.environment.background_color = g.settings.bg_color_3d[image_idx]
			we.get_child(0).hide()
			$VB2.hide()
		PICTURE:
			we.environment.background_mode = Environment.BG_CANVAS
			we.get_child(0).show()
			$VB2.hide()
		PANORAMA:
			$VB2.show()
			we.get_child(0).hide()
			we.environment.background_mode = Environment.BG_SKY
			if sky.panorama:
				we.environment.background_sky = sky
	set_env_energy()
	$Mode.text = bg_modes[bg_mode]
	$Mode.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property($Mode, "modulate:a", 0.0, 1.0)


func resize_bg():
	var img = we.get_child(0).texture
	if img:
		var canvas_size = get_viewport().get_visible_rect().size
		var img_size = img.get_size()
		var sc = max(canvas_size.x / img_size.x, canvas_size.y / img_size.y)
		we.get_child(0).scale = Vector2(sc, sc)


func _on_VSlider1_value_changed(value):
	emit_signal("slider1_changed", value)


func _on_VSlider2_value_changed(value):
	g.settings.env_brightness[1] = value
	set_env_energy()


func set_env_energy():
	var energy = 0
	if g.settings.bg_modes[image_idx] == PANORAMA:
		energy = g.settings.env_brightness[1] / 100.0
	we.environment.background_energy = energy
