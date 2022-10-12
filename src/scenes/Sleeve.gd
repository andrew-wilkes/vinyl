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
	mesh.surface_get_material(0).set_shader_param("side_a", side_a)
	mesh.surface_get_material(0).set_shader_param("side_b", side_b)
	mesh.surface_get_material(0).set_shader_param("edge_color", edge_color)
