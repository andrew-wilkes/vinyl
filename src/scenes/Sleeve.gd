extends MeshInstance

const DISPLACEMENT = 0.25

var revealed = false
var tween
var album_id

func reveal():
	var d = DISPLACEMENT
	tween = get_tree().create_tween()
	if revealed:
		d = -d
	tween.tween_property(self, "translation", Vector3(translation.x, translation.y, translation.z + d), 0.3).from_current()
	revealed = !revealed


func set_textures(side_a, side_b, edge_color):
	var mat = get_surface_material(0)
	mat.set_shader_param("edge_color", edge_color)
	if side_a:
		var img_a = g.get_resized_texture(side_a).texture
		mat.set_shader_param("side_a", img_a)
	if side_b:
		var img_b = g.get_resized_texture(side_b).texture
		mat.set_shader_param("side_b", img_b)
