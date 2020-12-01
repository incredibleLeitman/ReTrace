extends Spatial

var _animation: AnimationPlayer


func _ready():
	_animation = get_parent().get_node("PillAnimationPlayer") as AnimationPlayer
	assert(null != _animation)


func _process(delta):
	# Taking a pill
	if Input.is_action_just_pressed("take_pill"):
		#Logger.info("Player took a pill, new level: %s" % [Pills.get_round_level()])
		_animation.play("PillTaking")
		yield(_animation, "animation_finished")
		Pills.take_pill()