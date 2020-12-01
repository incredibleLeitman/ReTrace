extends StaticBody
class_name Keycard

export(int) var card_lvl

onready var outline = get_node("KeycardMesh/Outline") as MeshInstance


func _ready ():
	if Inventory.contains_item_with_name(self.name):
		Logger.info("keycard allready collected: TODO: delete")
		queue_free()


func do_interact(var player):
	if card_lvl > player.keycard_lvl:
		player.keycard_lvl = card_lvl
	queue_free()


func is_class(type): return type == "Keycard" or .is_class(type)


func get_class(): return "Keycard"