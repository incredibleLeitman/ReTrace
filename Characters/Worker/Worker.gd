extends NPC

const diffPerSecond = 5
var _arrived_distance_threshold = 0.1

var _navPath: Path
var _followPath: PathFollow
var _current_nav_index = 0

func _ready():
	_followPath = get_node("../") as PathFollow
	_navPath = get_node("../../") as Path

func _process(_delta):
	if _followPath != null:
		_followPath.offset += diffPerSecond * _delta
		if _followPath.unit_offset > 0.99:
			#Logger.info("freeing worker! name: " + name)
			queue_free()