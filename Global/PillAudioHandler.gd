extends Node


export(float) var true_begin_threshold = 0.75
export(float) var masked_begin_threshold = 0.4
export(float) var max_volume = 0.15
export(float) var min_pitch_scale = 0.9  # The pitch won't go down lower than this when the player is sober


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_volumes()
	
	set_master_db(linear2db(max_volume))


func set_masked_db(db_val):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Masked"), db_val)


func set_true_db(db_val):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("True"), db_val)


func set_master_db(db_val):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db_val)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_volumes()


func _update_volumes():
	var level = Pills.get_normalized_level()
	
	if level < masked_begin_threshold:
		set_masked_db(linear2db(0.0))
		set_true_db(linear2db(max_volume))
	elif level < true_begin_threshold:
		# Get the distance between the masked and true thresholds as a value between 0 and 1
		var normalized_distance_within_thresholds = inverse_lerp(masked_begin_threshold, true_begin_threshold, level)
		
		# Scale volumes accordingly
		set_masked_db(linear2db(normalized_distance_within_thresholds * max_volume))
		set_true_db(linear2db((1.0 - normalized_distance_within_thresholds) * max_volume))
	else:
		set_masked_db(linear2db(max_volume))
		set_true_db(linear2db(0.0))
	
	# Decrease the pitch when the player is sober
	var pitch = lerp(min_pitch_scale, 1.0, level)
	
	AudioServer.get_bus_effect(AudioServer.get_bus_index("Master"), 0).pitch_scale = pitch
