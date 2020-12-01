extends StaticBody

export(Color) var col1
export(Color) var col2
export(Color) var col3
export(Color) var col4
export(Color) var col5

onready var _lever = get_node("Lever") as StaticBody
onready var _light1 = get_node("Lights/Light1") as MeshInstance
onready var _light2 = get_node("Lights/Light2") as MeshInstance
onready var _light3 = get_node("Lights/Light3") as MeshInstance
onready var _out1 = get_node("IO Boxes/Output1") as MeshInstance
onready var _out2 = get_node("IO Boxes/Output2") as MeshInstance
onready var _out3 = get_node("IO Boxes/Output3") as MeshInstance

var _exit_box_num
var _req_exit_color : Color
var _out_colors : Array
var _out_boxes : Array 
var _lights : Array
var _all_colors : Array 
var _rng = RandomNumberGenerator.new()
var _is_running = false
var _colors_should_be_updated = false

# constant variables
const OUT_BOX_DEFAULT_COLOR = Color(0.4, 0.4, 0.4, 1)
const OUT_BOX_HIGHLIGHT_COLOR = Color(0.6, 0.6, 0.6, 1)
const NULL_COLOR = Color(0, 0, 0, 1)


func _ready():
	_rng.randomize()
	
	_out_boxes = [_out1, _out2, _out3]
	_lights = [_light1, _light2, _light3]
	_all_colors = [col1, col2, col3, col4, col5]
	
	_lever.connect("start_machine", self, "_setup_next_combo")
	
	var inputs = get_tree().get_nodes_in_group("InputBoxes")
	var counter = 0
	for i in inputs:
		i.content_color = _all_colors[counter]
		i.load_content_color()
		counter+=1


func _process(delta: float) -> void:
	var pipes = get_tree().get_nodes_in_group("Pipes")

	for p in pipes:
		p.update_content_color(_all_colors)
	
	if _is_running and not _exit_box_num == null:
		var collider = _out_boxes[_exit_box_num].get_node("ExitCast").get_collider()
		if collider.is_in_group("Pipes"):
			var new_color = collider.content_color
			if new_color != null:
				if _col_compare(new_color, _req_exit_color):
					_lever.blocked = false
					_lever.flick()
					_is_running = false
					_reset_out_boxes()
					print("Game Won!")


func _col_compare(var col1, var col2):
	if col1.r < col2.r - 0.001 or col1.r > col2.r + 0.001:
		return false
	elif col1.g < col2.g - 0.001 or col1.g > col2.g + 0.001:
		pass
	elif col1.b < col2.b - 0.001 or col1.b > col2.b + 0.001:
		pass
	else:
		return true


func _setup_next_combo():
	_reset_out_boxes()
	_out_colors.clear()
	_req_exit_color = NULL_COLOR
	
	_exit_box_num = _rng.randi()%3
	
	_gen_next_col()
	_gen_next_col()
	_gen_next_col()
	
	_set_exit_colors(_out_boxes[_exit_box_num])
	_lever.blocked = true
	_is_running = true


func _gen_next_col():
	var next_col = _rng.randi()%5
	while _out_colors.has(next_col):
		next_col = _rng.randi()%5
	_out_colors.append(next_col)


func _set_exit_colors(var box_path):
	var material = SpatialMaterial.new()
	material.albedo_color = OUT_BOX_HIGHLIGHT_COLOR
	material.emission_enabled = true
	material.emission = OUT_BOX_HIGHLIGHT_COLOR
	box_path.material_override = material
	
	var counter = 0
	for l in _lights:
		var material2 = SpatialMaterial.new()
		material2.albedo_color = _all_colors[_out_colors[counter]]
		material2.emission_enabled = true
		material2.emission = _all_colors[_out_colors[counter]]
		l.material_override = material2
		
		_req_exit_color += material2.albedo_color / 3

		counter+=1
	_req_exit_color.a = 1


func _reset_out_boxes():
	var material = SpatialMaterial.new()
	material.albedo_color = OUT_BOX_DEFAULT_COLOR
	_out1.material_override = material
	_out2.material_override = material
	_out3.material_override = material
	
	var material2 = SpatialMaterial.new()
	_light1.material_override = material2
	_light2.material_override = material2
	_light3.material_override = material2