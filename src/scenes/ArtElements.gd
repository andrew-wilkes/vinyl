extends VBoxContainer

signal added_element(el)
signal selected_element(el)
signal removed_element(el)
signal moved_element(from, to)

onready var elements = $"%Elements"

var selected_item = -1

func init_elements(els):
	elements.clear()
	var idx = 0
	for el in els:
		elements.add_icon_item($Grid.get_child(el.type).icon.duplicate())
		elements.set_item_metadata(idx, el)
		idx += 1


func add_element(type):
	var el = ArtElement.new()
	el.type = type
	elements.add_icon_item($Grid.get_child(el.type).icon.duplicate())
	selected_item = elements.get_item_count() - 1
	update_up_down_buttons()
	elements.set_item_metadata(selected_item, el)
	elements.select(selected_item)
	match el.type:
		el.AB:
			el.position = Vector2(0.2, 0.5)
			el.rotation = 0.5
			el.size = 0.5
		el.ABROT:
			el.length = 0.3
			el.position = Vector2(0.8, 0.8)
			el.rotation = 0.5
			el.size = 0.5
		el.ARC:
			el.size = 0.2
			el.length = 0.3
			el.position = Vector2(0.5, 0.5)
			el.rotation = 0.5
		el.BOX, el.SQR:
			el.size = 0.2
			el.length = 0.3
			el.position = Vector2(0.2, 0.2)
			el.rotation = 0.5
		el.CIRC, el.DOT:
			el.size = 0.7
			el.position = Vector2(0.8, 0.8)
		el.LINE:
			el.size = 0.2
			el.length = 0.5
			el.position = Vector2(0.25, 0.25)
			el.rotation = 0.5
	emit_signal("added_element", el)


func _unhandled_key_input(event):
	if event.scancode == KEY_DELETE and selected_item > -1:
		emit_signal("removed_element", elements.get_item_metadata(selected_item))
		elements.remove_item(selected_item)
		selected_item = -1
		update_up_down_buttons()


func _on_AB_pressed():
	add_element(ArtElement.AB)


func _on_ABRot_pressed():
	add_element(ArtElement.ABROT)


func _on_Circle_pressed():
	add_element(ArtElement.CIRC)


func _on_Arc_pressed():
	add_element(ArtElement.ARC)


func _on_Line_pressed():
	add_element(ArtElement.LINE)


func _on_Dot_pressed():
	add_element(ArtElement.DOT)


func _on_Square_pressed():
	add_element(ArtElement.SQR)


func _on_Box_pressed():
	add_element(ArtElement.BOX)


func _on_Elements_item_selected(index):
	selected_item = index
	update_up_down_buttons()
	emit_signal("selected_element", elements.get_item_metadata(selected_item))


func _on_Up_pressed():
	elements.move_item(selected_item, selected_item - 1)
	emit_signal("moved_element", selected_item, selected_item - 1)
	selected_item -= 1
	update_up_down_buttons()


func _on_Down_pressed():
	elements.move_item(selected_item, selected_item + 1)
	emit_signal("moved_element", selected_item, selected_item + 1)
	selected_item += 1
	update_up_down_buttons()


func update_up_down_buttons():
	$"%Up".disabled = selected_item < 1
	$"%Down".disabled = elements.get_item_count() - 1 == selected_item or selected_item < 0
