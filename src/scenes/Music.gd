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
const vspace = 0.32

onready var wood = $Shelves/Wood
onready var lp = $LP


func _ready():
	build_shelves(3, 2)


func build_shelves(num_levels, width):
	# Sides
	wood.translation = Vector3(-(width - plank_wood) / 2, 0, outer_depth / 2.0 - thin_wood)
	wood.depth = outer_depth
	wood.height = num_levels * (vspace + plank_wood) - plank_wood
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
	for n in num_levels - 1:
		y += vspace + plank_wood
		var s = shelf
		if n > 0:
			s = shelf.duplicate()
		s.translation.y = y
		s.name = "SHELF" + str(n + 1)
		$Shelves.add_child(s)
