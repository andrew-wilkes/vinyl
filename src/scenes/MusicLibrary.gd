extends Spatial

# Wood: 6mm or 18mm or 24mm thickness
# LP: 31cm x 31cm x 6mm
# Position inner back wall at z = 0
# Back wall is inset

const thin_wood = 0.006
const plank_wood = 0.018
const thick_wood = 0.024
const shelf_depth = 0.32
const outer_depth = 0.34
const vspace = 0.34
const record_thickness = 0.006
const record_size = 0.31
const record_gap = 0.008

onready var wood = $Shelves/Wood
onready var lp = $LP

var xoff: int
var yoff: int
var x_spacing
var y_spacing

func _ready():
	build_shelves(50, 3)
	lp.translation = get_record_position(0, 0)
	var x = lp.translation.x
	for n in 30:
		x += record_gap + record_thickness
		var lp2 = lp.duplicate()
		lp2.translation.x = x
		add_child(lp2)
		lp2.get_child(0).connect("mouse_entered", self, "edge_entered", [lp2])
		lp2.get_child(0).connect("mouse_exited", self, "edge_exited", [lp2])
		lp2.get_child(0).connect("input_event", self, "edge_input", [lp2])
		lp2.material = lp.material.duplicate()
		lp2.material.next_pass = lp.material.next_pass.duplicate()


func edge_entered(item):
	item.material.next_pass.set_shader_param("Level", 1.0)


func edge_exited(item):
	item.material.next_pass.set_shader_param("Level", 0.0)


func edge_input(_camera, event, _position, _normal, _shape_idx, item):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		print(item)


func calc_cabinet_width(x_capacity):
	x_spacing = record_thickness + record_gap
	return x_capacity * (record_thickness + record_gap) + record_gap + 2 * plank_wood


func calc_offset(capacity: int):
# warning-ignore:integer_division
	return -(capacity - 1) / 2


func get_record_position(x: int, y: int):
	return Vector3((xoff + x) * x_spacing, (yoff + y) * y_spacing - (vspace - record_size) / 2, record_size / 2)


func build_shelves(x_capacity: int, y_capacity: int):
	xoff = calc_offset(x_capacity)
	yoff = calc_offset(y_capacity)
	var width = calc_cabinet_width(x_capacity)
	y_spacing = vspace + plank_wood
	# Sides
	wood.translation = Vector3(-(width - plank_wood) / 2, 0, outer_depth / 2.0 - thin_wood)
	wood.depth = outer_depth
	wood.height = y_capacity * y_spacing - plank_wood
	wood.name = "LEFT"
	var right_side = wood.duplicate()
	right_side.translation.x *= -1
	right_side.name = "RIGHT"
	$Shelves.add_child(right_side)
	var base = wood.duplicate()
	base.height = thick_wood
	base.width = width
	base.translation.x = 0
	base.translation.y = -(right_side.height + thick_wood) / 2.0
	base.name = "BASE"
	$Shelves.add_child(base)
	var top = base.duplicate()
	top.name = "TOP"
	top.translation.y *= -1
	$Shelves.add_child(top)
	var back = wood.duplicate()
	back.depth = thin_wood
	back.width = width - 2 * plank_wood
	back.translation = Vector3(0, 0, -thin_wood / 2.0)
	back.name = "BACK"
	$Shelves.add_child(back)
	var shelf = back.duplicate()
	shelf.height = plank_wood
	shelf.depth = shelf_depth
	shelf.translation.z = shelf_depth / 2.0
	var y = -(wood.height + plank_wood) / 2.0
	for n in y_capacity - 1:
		y += vspace + plank_wood
		var s = shelf
		if n > 0:
			s = shelf.duplicate()
		s.translation.y = y
		s.name = "SHELF" + str(n + 1)
		$Shelves.add_child(s)
