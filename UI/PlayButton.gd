extends Button

func _ready():
	pass # Replace with function body.


func _on_PlayButton_pressed():
	get_tree().change_scene("res://Level/OutsideWorld.tscn")
