extends Node

var items: Array

func _ready():
	pass # Replace with function body.


func add_item (item):
	if items.has(item):
		return

	items.append(item)


func contains_item (item):
	return items.has(item)


func contains_item_with_name (name):
	for item in items:
		if item.name == name:
			return true


func get_items ():
	return items


func clear ():
	items.clear()