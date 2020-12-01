extends StaticBody

onready var outline = get_node("Outline") as MeshInstance


func do_interact(var player):
	get_tree().quit()
