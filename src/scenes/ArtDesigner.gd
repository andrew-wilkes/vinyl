extends PanelContainer

func disable_input(disable = true):
	$HB/VB/ImageView/Viewport.gui_disable_input = disable


func init_canvas(idx, album):
	$HB/VB/Title.text = ["Label design", "Label design", "Cover design", "Cover design"][idx]
	$HB/VB/ImageView.is_disc = idx < 2
	$HB/VB/VB/HB/BG.texture = null
	$HB/VB/ImageView.image = null
	var image_path = album.bg.get("image", null)
	if image_path:
		var file = File.new()
		if file.file_exists(image_path):
			var bg_texture = load(image_path)
			$HB/VB/VB/HB/BG.texture = bg_texture
			$HB/VB/ImageView.image = bg_texture
	var color = album.bg.get("color", Color.white)
	$HB/VB/ImageView.mod_color = color
	$HB/VB/VB/HB/ModColor.color = color
	var hsv = rgb_to_hsv(color)
	$HB/VB/VB/HB/Adjusters/H.value = hsv.h
	$HB/VB/VB/HB/Adjusters/S.value = hsv.s
	$HB/VB/VB/HB/Adjusters/V.value = hsv.v
	$HB/VB/VB/HB/Adjusters/A.value = color.a
	$ArtElements/Elements.init_elements(album.elements)


func set_hole_size(large = true):
	if large:
		$HB/VB/ImageView.hole_size = 0.3
	else:
		$HB/VB/ImageView.hole_size = 0.1


func rgb_to_hsv(c: Color):
	var rgb = [c.r, c.g, c.b]
	var M: float = rgb.max()
	var m: float = rgb.min()
	var v = M
	var s = 0.0 if M < 0.001 else 1.0 - m / M
	var h = (c.r - c.g / 2.0 - c.b / 2.0) / sqrt(c.r*c.r + c.g*c.g + c.b*c.b - c.r*c.g - c.r*c.b - c.g*c.b)
	return { h=h, s=s, v=v }
