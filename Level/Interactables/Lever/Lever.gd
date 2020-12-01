extends StaticBody

#export variables
export(bool) var is_on = false
export(bool) var is_color_input = false
export(bool) var is_machine_start = false

onready var lever_mesh = get_node("LeverMesh")
onready var outline = get_node("LeverMesh/Outline") as MeshInstance

var blocked = false

# signals
signal flow_changed
signal start_machine

func do_interact(var player):
	if not blocked:
		flick()
		
		if is_color_input:
			emit_signal("flow_changed")
		if is_machine_start:
			emit_signal("start_machine")

func flick():
	set_scale(Vector3(scale.x, -scale.y, scale.z))
	is_on = !is_on
