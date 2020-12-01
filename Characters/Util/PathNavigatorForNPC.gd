extends Path

var _current_nav_path: PoolVector3Array

var _current_nav_index
var _current_path_index

var _arrived_distance_threshold = 0.1

export(NodePath) var body_nodepath

var navigation: Navigation
var body: NPC


# React to the NodeGroupNotifier of the Navigation
func set_navigator_node(navigation_node: Navigation):
	navigation = navigation_node as Navigation
	
	# Our path could change significantly with the Navigation node, so restart
	_restart_navigation()


func _ready():
	_restart_navigation()


# Reset the body to the starting position and start the navigation freshly
func _restart_navigation():
	_current_nav_index = 0
	_current_path_index = 1
	
	body = get_node(body_nodepath) as KinematicBody

	# Initialize the position
	body.set_position(curve.get_point_position(0))
	
	# Get the first goal
	_get_new_navigation()


func _process(delta):
	# Use either the NPC's current target or the paths next goal
	var current_goal = body.current_target if body.current_target else _get_current_goal()
	
	# Move towards the current goal
	var direction_normalized: Vector3 = (current_goal - _get_body_position()).normalized()
	
	body.look_towards(direction_normalized)
	body.move_towards(direction_normalized * body.speed)


# Returns the point we should currently be moving towards
func _get_current_goal():
	# If we haven't arrived at the current goal, then that's still the goal
	if _current_nav_path[_current_nav_index].distance_to(_get_body_position()) > _arrived_distance_threshold:
		return _current_nav_path[_current_nav_index]
	
	if _current_nav_index < _current_nav_path.size() - 1:
		# We still have points left in the current navigation -> use the next one
		# TODO: using log levels/categories
		#Logger.trace("Using next point of current navigation")
		_current_nav_index += 1
	else:
		# We're done following the current navigation to the next path point
		if _current_path_index < curve.get_point_count() - 1:
			# We still have points left in the path -> use the next one and generate the navigation to it
			#Logger.trace("Generating navigation to the next path point")
			_current_path_index += 1
		else:
			# We're done following the path -> Go back to the start
			#Logger.trace("Returning to the start of the path")
			_current_nav_index = 0
			_current_path_index = 0
		
		_get_new_navigation()
	
	return _current_nav_path[_current_nav_index]


# Reset the navigation and build a new one for the current path index
func _get_new_navigation():
	_current_nav_index = 0
	
	var goal = curve.get_point_position(_current_path_index)
	
	if navigation:
		_current_nav_path = navigation.get_simple_path(_get_body_position(), goal)
	else:
		_current_nav_path = PoolVector3Array([goal])


# Return the current position of the body we're controlling
func _get_body_position():
	return body.transform.origin
