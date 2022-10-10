extends CSGBox

const DISPLACEMENT = 0.25

var revealed = false
var tween

func reveal():
	var d = DISPLACEMENT
	tween = get_tree().create_tween()
	if revealed:
		d = -d
	tween.tween_property(self, "translation", Vector3(translation.x, translation.y, translation.z + d), 0.3).from_current()
	revealed = !revealed
