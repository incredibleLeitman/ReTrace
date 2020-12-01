extends VBoxContainer


onready var embark = get_node("EmbarkControls")
onready var credits = get_node("CreditsControls")


func _ready():
	show_embark()
	
	embark.get_node("VBoxContainer/CreditsButton").connect("button_up", self, "show_credits")
	credits.get_node("VBoxContainer/BackButton").connect("button_up", self, "show_embark")


func show_embark():
	embark.visible = true
	credits.visible = false


func show_credits():
	embark.visible = false
	credits.visible = true