extends Node

const _max: int = 1440 # 24 hour + 60 mins

const WORK_TIME = _max * 0.3
const SLEEP_TIME = _max * 0.6
const TIGGER_TIME = _max * 0.2

var _time: float = 0 setget _set_time, get_time
var _prev_time: float = _time
var increase_per_second: float = 7.0

signal respawn
signal go_to_work
signal go_home


func _set_time (new_time: float):
	_time = new_time


func get_time () -> float:
	return _time


func get_max () -> int:
	return _max


func _process (delta: float) -> void:
	# continually increases daytime
	_time = _time + increase_per_second * delta
	if _time >= _max:
		_time = 0
		emit_signal("respawn")

	if _prev_time < WORK_TIME - TIGGER_TIME and _time > WORK_TIME - TIGGER_TIME:
		Logger.info("time to go to work @" + String(_time))
		emit_signal("go_to_work")
	if _prev_time < SLEEP_TIME and _time > SLEEP_TIME:
		Logger.info("time to go home @" + String(_time))
		emit_signal("go_home")

	_prev_time = _time
