extends Spatial

const DISPLACEMENT = 0.25

var revealed = false
var tween
var album_id

func _ready():
	$Sleeve/disc.translation.z = 0

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


func animate(pos):
	if pos < 30:
		var ang = (30.0 - pos) / 30.0
		if ang < 0.1: ang = 0.0
		if ang > 0.9: ang = 1.0
		rotate_object(Vector3.UP, $Sleeve, ang)
		$Sleeve/disc.translation.z = 0
		rotate_object(Vector3.FORWARD, $Sleeve/disc, 0.5)
	elif pos > 35 and pos < 65:
		$Sleeve/disc.translation.z = -0.33 * (pos - 35.0) / 30.0
		rotate_object(Vector3.FORWARD, $Sleeve/disc, 0.5)
		rotate_object(Vector3.UP, $Sleeve, 0.0)
	elif pos > 70:
		var ang = (pos - 70.0) / 30.0 + 0.5
		if ang < 0.6: ang = 0.5
		if ang > 1.4: ang = 1.5
		rotate_object(Vector3.FORWARD, $Sleeve/disc, ang)
		$Sleeve/disc.translation.z = -0.33
		rotate_object(Vector3.UP, $Sleeve, 0.0)
	if pos > 85:
		$Sleeve/disc.rotation.x = -PI / 2
	else:
		$Sleeve/disc.rotation.x = PI / 2


func rotate_object(axis, ob, amount):
	ob.transform.basis = Basis() # reset rotation
	ob.rotate_object_local(axis, amount * PI)
