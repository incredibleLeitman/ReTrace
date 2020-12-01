extends Spatial

export(NodePath) var _nodepath
export(float) var _offset
export(bool) var ToFactory = true # otherwise it's FromFactory

const SPAWN_TIME_MIN = 1000 # min spawntime in ms
const SPAWN_TIME_MAX = 3000 # max spawntime in ms

var _worker = preload("res://Characters/Worker/Worker.tscn")
var _lastSpawn = 0	# timestamp of last spawned worker
var _path: Path
var diff = 0

func _ready():
	assert(null != _worker)

	_path = get_node(_nodepath)
	assert(null != _path)


func _process(delta):
	var day_time = Daytime.get_time()
	if ToFactory:
		if day_time > Daytime.WORK_TIME:
			return
	elif day_time < Daytime.SLEEP_TIME:
		return

	# spawns new workers after defined time
	var cur_time = OS.get_ticks_msec()
	if cur_time - _lastSpawn > diff:
		var pathFollow = PathFollow.new()
		pathFollow.offset = _offset
		var worker = _worker.instance()
		pathFollow.add_child(worker)
		_path.add_child(pathFollow)
		_lastSpawn = cur_time
		#Logger.info(name + " spawning new worker: " + worker.name + ". daytime " + String(day_time) + " <-> " + String(Daytime.WORK_TIME))
		
		diff = rand_range(SPAWN_TIME_MIN, SPAWN_TIME_MAX)
