extends KinematicBody
class_name NPC


export(float) var turn_speed = 2.5
export(float) var speed = 8

var current_target
var current_look_target


func _process(delta):
	if current_look_target:
		var diff_raw = (current_look_target - -transform.basis.z)
		
		# Don't look up/down, only rotate on XZ plane
		var diff = Vector3(diff_raw.x, 0.0, diff_raw.z)
		
		# For the target, move the current forward direction towards the desired one
		var target = -transform.basis.z + diff * turn_speed * delta
		
		if diff.length() > 0.1:
			look_at(transform.origin + target, Vector3.UP)
	
	if current_target:
		# Move towards the current goal
		var direction_normalized: Vector3 = (current_target - transform.origin).normalized()
		
		look_towards(direction_normalized)
		move_towards(direction_normalized * speed)


func set_position(position: Vector3):
	transform.origin = position


func move_towards(direction_times_speed: Vector3):
	# Decrease the speed depending on the difference between the look direction and the move direction
	# This makes the NPC stop when turning, and only start moving once it has moved its gaze there
	var speed_dir_factor = 1.0 - (-transform.basis.z.normalized() - direction_times_speed.normalized()).length() / 2.0
	
	move_and_slide(direction_times_speed * speed_dir_factor)


func look_towards(direction: Vector3):
	current_look_target = direction
