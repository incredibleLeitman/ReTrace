extends StaticBody 
class_name Key

export(int) var key_id

onready var outline = get_node("KeyMesh/Outline") as MeshInstance


func _ready ():
	if Inventory.contains_item_with_name(self.name):
		Logger.info("key allready collected: TODO: delete")
		queue_free()


func do_interact(var player):
	player.key_chain.append(key_id)
	queue_free()


func is_class(type): return type == "Key" or .is_class(type)


func get_class(): return "Key"