extends Area


onready var rays = get_node("../InteractCheckRays")

var max_distance = 40


func _process(delta: float) -> void:
	var new_scale = 1.0
	
	for ray in rays.get_children():
		var collision_point = ray.get_collision_point()
		
		if collision_point:
			var distance = collision_point.distance_to(global_transform.origin)
			
			if distance < max_distance:
				var potential_new_scale = distance / max_distance
				
				if potential_new_scale < new_scale:
					new_scale = potential_new_scale
	
	scale = Vector3(new_scale, new_scale, new_scale)
	translation.y = 2.3 + (1.0 - new_scale) * 2.0  # Need to compensate for offset caused by y translation