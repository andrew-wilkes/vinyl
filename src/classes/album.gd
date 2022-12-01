extends Resource

class_name Album

export var title = ""
export var band = ""
export var genre = ""
export var size = ""
export var rpm = ""
export var pitch = 0.23
export var images = [null, null, null, null]
export var elements = [[], [], [], []]
export var bg = [{}, {}, {}, {}] # Background { "color": color, "image": "path" }, ...
export var a_side: Array
export var b_side: Array
export var label_color = Color.white
export var shelf_pos  = { "x": 0, "y": 0 }
