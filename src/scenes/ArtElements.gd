extends VBoxContainer

signal added_element(el)
signal selected_element(el)

export var tab = 0

var selected_item = -1
var album: Album

func _ready():
	album = Album.new()


func add_element(type):
	var el = ArtElement.new()
	el.type = type
	album.elements[tab].append(el)
	$Elements.add_icon_item($Grid.get_child(el.type).icon.duplicate())
	selected_item = $Elements.get_item_count() - 1
	$Elements.set_item_metadata(selected_item, el)
	$Elements.select(selected_item)
	emit_signal("added_element", el)


func _unhandled_key_input(event):
	if event.scancode == KEY_DELETE and selected_item > -1:
		album.elements[tab].erase($Elements.get_item_metadata(selected_item))
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
