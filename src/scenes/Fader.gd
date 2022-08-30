extends ColorRect

export var fade_in_enabled = true
export var fade_out_enabled = true

var target_scene

func _ready():
	# Reveal from center outwards
	if fade_in_enabled:
		show()
		$Anim.play("FadeIn")
	else:
		hide()


func fade_out(scene):
	target_scene = scene
	if fade_out_enabled:
		material.set_shader_param("aspect", rect_size.normalized())
		show()
		$Anim.play("FadeOut")
	else:
		change_scene()


func _on_Anim_animation_finished(anim_name):
	if anim_name == "FadeOut":
		change_scene()
	else:
		hide()


func change_scene():
	var _e = get_tree().change_scene("res://scenes/" + target_scene + ".tscn")
