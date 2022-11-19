extends Spatial

const DISPLACEMENT = 0.25

var revealed = false
var tween
var album_id
var anim_target_position = 0.33

func _ready():
	# Set start position so as not to start animating
	$Anim.seek(0.385)


func set_lights(show):
	$DirectionalLight.visible = show
	$DirectionalLight2.visible = show


func reveal():
	var d = DISPLACEMENT
	tween = get_tree().create_tween()
	if revealed:
		d = -d
	tween.tween_property(self, "translation", Vector3(translation.x, translation.y, translation.z + d), 0.3).from_current()
	revealed = !revealed


func set_textures(album, edge_color):
	var mat = $Sleeve.get_surface_material(0)
	mat.set_shader_param("edge_color", edge_color)
	var img_a = g.get_resized_texture(album.images[2]).texture if album.images[2] else null
	mat.set_shader_param("side_a", img_a)
	var img_b = g.get_resized_texture(album.images[3]).texture if album.images[3] else null
	mat.set_shader_param("side_b", img_b)
	mat = $Sleeve/disc.get_surface_material(0)
	img_a = g.get_resized_texture(album.images[0]).texture if album.images[0] else null
	mat.set_shader_param("label_a", img_a)
	img_b = g.get_resized_texture(album.images[1]).texture if album.images[1] else null
	mat.set_shader_param("label_b", img_b)


func _process(_delta):
	if abs(anim_target_position - $Anim.current_animation_position / 1.5) < 0.01:
		if $Anim.is_playing():
			$Anim.stop(false)
	else:
		if anim_target_position > $Anim.current_animation_position / 1.5:
			if not $Anim.is_playing() or $Anim.playback_speed < 0.5:
				$Anim.play("Animate")
		else:
			if not $Anim.is_playing() or $Anim.playback_speed > 0.5:
				$Anim.play_backwards("Animate")


func animate(pos):
	anim_target_position = pos / 100.0


func _on_HSlider_value_changed(value):
	anim_target_position = value / 100.0
