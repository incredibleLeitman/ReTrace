extends Node


onready var inactive_music = get_node("InactiveMusic")
onready var active_music = get_node("ActiveMusic")

export(NodePath) var path_to_pipegame

var pipegame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inactive_music.play()
	
	pipegame = get_node(path_to_pipegame)
	
	pipegame.get_node("Lever").connect("start_machine", self, "activate_active_music")


func activate_active_music():
	active_music.play(inactive_music.get_playback_position())
	inactive_music.stop()
