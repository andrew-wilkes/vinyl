extends VBoxContainer

signal added_element(el)
signal selected_element(el)
signal removed_element(el)

var selected_item = -1

func init_elements(elements):
	$Elements.clear()
	var idx = 0
	for el in elements:
		$Elements.add_icon_item($Grid.get_child(el.type).icon.duplicate())
		$Elements.set_item_metadata(idx, el)
		idx += 1


func add_element(type):
	var el = ArtElement.new()
	el.type = type
	$Elements.add_icon_item($Grid.get_child(el.type).icon.duplicate())
	selected_item = $Elements.get_item_count() - 1
	$Elements.set_item_metadata(selected_item, el)
	$Elements.select(selected_item)
	match el.type:
		el.AB:
			el.position = Vector2(0.2, 0.5)
			el.rotation = 0.5
		el.ABROT:
			el.length = 0.3
			el.position = Vector2(0.8, 0.8)
			el.rotation = 0.5
		el.ARC:
			el.size = 0.2
			el.length = 0.3
			el.position = Vector2(0.9, 0.9)
			el.rotation = 0.5
		el.BOX:
			el.size = 0.2
			el.length = 0.6
			el.position = Vector2(0.2, 0.2)
		el.CIRC:
			el.size = 0.7
			el.position = Vector2(0.8, 0.8)
	emit_signal("added_element", el)


func _unhandled_key_input(event):
	if event.scancode == KEY_DELETE and selected_item > -1:
		emit_signal("removed_element", $Elements.get_item_metadata(selected_item))
		$Elements.remove_item(selected_item)
		selected_item = -1


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
	emit_signal("selected_element", $Elements.get_item_metadata(selected_item))
