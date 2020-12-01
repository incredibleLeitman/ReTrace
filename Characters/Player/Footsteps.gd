extends Spatial


onready var steps = [
	get_node("Footstep1")
]


func play_footstep():
	#Logger.trace("Footstep")
	steps[0].play()