extends Node


var _min: float = 0.0
var _max: float = 6.0
var _level: float = _max setget _set_level, get_level
var _prev_level: float = _max
var _decrease_per_second: float = 0.15
var _pill_add_amount: float = 2.0

signal low_pill_level
signal very_low_pill_level

enum LEVELS {
	SOBRE = 0,
	VERY_LOW = 1,
	LOW = 2,
	MEDIUM = 3,
	HIGH = 4,
	VERY_HIGH = 5,
	FULL = 6
}


# Returns the max level
func get_max() -> float:
	return _max


# Returns the exact current level as a floating point number between min and max
func get_level() -> float:
	return _level


# Returns the currenct level as a floating point number between 0 and 1
func get_normalized_level() -> float:
	return _level / _max


# Returns the rounded level, e.g. for behavior which changes stepwise (X at level 6, Y at level 5, ...)
func get_round_level():
	return ceil(get_level())


func _set_level(new_level: float):
	# Make sure the level stays between min and max
	_level = clamp(new_level, _min, _max)


func _ready() -> void:
	# Start with the maximum druggedness
	_set_level(_max)


func _process(delta: float) -> void:
	# Gradually decrease the level by the decrease per second
	_set_level(_level - _decrease_per_second * delta)
	
	if _prev_level > LEVELS.VERY_LOW and _level < LEVELS.VERY_LOW:
		Logger.info("very low pill level")
		emit_signal("very_low_pill_level")
	elif _prev_level > LEVELS.MEDIUM and _level < LEVELS.MEDIUM:
		Logger.info("low pill level")
		emit_signal("low_pill_level")
	_prev_level = _level
	


func take_pill():
	_set_level(_level + _pill_add_amount)