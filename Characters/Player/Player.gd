extends KinematicBody

# export variables
export(NodePath) var body_nodepath
export(NodePath) var lookingAt_nodepath
export(NodePath) var animationWalk_nodepath
export(NodePath) var animationFadeOut_nodepath
export(NodePath) var ui_interact_nodepath
export(NodePath) var ui_message_nodepath
export(NodePath) var camera_nodepath
export(int) var keycard_lvl
export(Array) var key_chain

# const
const GRAVITY = -24.8
const JUMP_SPEED = 8
const MOVE_SPEED = 6
const SPRINT_SPEED = 10
const ACCEL = 15.0
const MAX_SLOPE_ANGLE = 40
const MOUSE_SENSITIVITY = 0.05
const INTERACT_DISTANCE = 4

# private members
var _body: Spatial
var _camera: Camera
var _lookCast: RayCast
var _animationWalk: AnimationPlayer
var _animationFadeOut: AnimationPlayer
var _labelInteract: Label
var _labelMessage: Label
var _dir = Vector3()
var _vel = Vector3()
var _is_sprinting : bool
var _illegal_areas : int
var _save_areas : int
var _work_areas : int
var _prev_look
var _inventory: Control

# public properties
#var IsSuspicios		# not needed > Meldewesen handles themselves
export(bool) var IsHunted 			# player is beeing flagged if one Meldewesen sees an illegal action
export(bool) var IsOutside = true	# active while player is not in factory
export(bool) var IsInFactory	= false	# only active in factory scene
export(bool) var IsInLabyrinth = false

func is_in_illegalzone ():
	return _illegal_areas > 0


func is_in_savezone ():
	return _save_areas > 0


func is_in_workzone ():
	return _work_areas > 0


func _ready():
	# Assign child node variables
	_body = get_node(body_nodepath) as Spatial # = $Body
	assert(null != _body)
	
	_camera = get_node(camera_nodepath) #as Camera
	assert(null != _camera)
	
	_animationWalk = get_node(animationWalk_nodepath) as AnimationPlayer
	assert(null != _animationWalk)
	
	_animationFadeOut = get_node(animationFadeOut_nodepath) as AnimationPlayer
	assert(null != _animationFadeOut)
	
	_labelInteract = get_node(ui_interact_nodepath) as Label
	assert(null != _labelInteract)
	
	_labelMessage = get_node(ui_message_nodepath) as Label
	assert(null != _labelMessage)
	
	# Setup mouse look
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_lookCast = get_node(lookingAt_nodepath) as RayCast
	_lookCast.cast_to = Vector3(0, 0, INTERACT_DISTANCE)
	
	_inventory = get_node("HUD")
	assert(null != _inventory)
	
	for object in Inventory.get_items():
		if object is Key:
			var key = object as Key
			key_chain.append(key)
		elif object is Keycard:
			var keycard = object as Keycard
			if keycard_lvl < keycard.card_lvl:
				keycard_lvl = keycard.card_lvl
	
	# Set special fast time when in labyrinth
	if IsInLabyrinth:
		Daytime.increase_per_second = 100
		Pills._decrease_per_second = 0.8
	
	# setup collisions with Meldewesen
	var area = get_node("InteractArea") as Area
	assert(null != area)
	area.connect("area_entered", self, "_on_area_entered")
	area.connect("area_exited", self, "_on_area_exited")

	Daytime.connect("respawn", self, "_on_respawn")
	Daytime.connect("go_home", self, "_on_go_home")
	Daytime.connect("go_to_work", self, "_on_go_to_work")

	Pills.connect("low_pill_level", self, "_on_pill_level_low")
	Pills.connect("very_low_pill_level", self, "_on_pill_level_very_low")

	if IsOutside:
		var player = get_node("AudioStreamPlayer3D")
		player.stream = load("res://Resources/Audio/cock.wav")
		player.play()

		# only message Player at the beginning
		if Daytime.get_time() < 10:
			showMessage("Press 'F' to eat your food", 4)


func showMessage (text, duration):
	_labelMessage.text = text
	# animation
	var timer = _inventory.get_node("Timer") as Timer
	timer.wait_time = duration
	timer.start()
	_labelMessage.show()
	yield(timer, "timeout")
	_labelMessage.hide()


func _physics_process(delta):
	process_input()
	process_movement(delta)
	process_collision_layers()

func _process(_delta):
	check_interact()
	process_animations()

func process_input():
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	# Walking
	var input_movement_vector = Vector2()
	if Input.is_action_pressed("move_fwrd"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("move_back"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("move_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_movement_vector.x += 1
	
	# look around with mouse
	_dir = Vector3()
	var camera_transform = _camera.get_global_transform()
	_dir += -camera_transform.basis.z * input_movement_vector.y
	_dir += camera_transform.basis.x * input_movement_vector.x
	
	# jumping
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		_vel.y = JUMP_SPEED

	# sprinting
	_is_sprinting = Input.is_action_pressed("move_sprint")


func process_movement(delta):
	_vel.y += delta * GRAVITY

	# set movement speed
	var target = _dir * (SPRINT_SPEED if _is_sprinting else MOVE_SPEED)

	var hvel = _vel
	hvel = hvel.linear_interpolate(target, ACCEL * delta)
	_vel.x = hvel.x
	_vel.z = hvel.z
	_vel = move_and_slide(_vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))


func process_animations():
	_animationWalk.playback_speed = _vel.length() / MOVE_SPEED


func process_collision_layers():
	var new_layer: int = 6
	
	if Pills.get_level() >= Pills.LEVELS.VERY_LOW:
		# If the masked view is almost invisible, collision with masked objects is disabled
		new_layer -= 1  # See collision layer names in editor
	
	collision_layer = new_layer
	collision_mask = new_layer


func check_interact():
	if _lookCast.is_colliding():
		var collider = _lookCast.get_collider()
		if null != collider and collider.is_in_group("Touchables"):
			#show interact tooltip
			if collider.is_in_group("HideTooltip") == false:
				_labelInteract.show()

			#enable outline of seen object
			collider.outline.show()
			if _prev_look != null and is_instance_valid(_prev_look):
				if _prev_look != collider:
					_prev_look.outline.hide()
			_prev_look = collider

			#do interaction
			if Input.is_action_just_pressed("interact"):
				collider.do_interact(self)
				if collider.is_in_group("Collectibles"):
					Logger.info("should add collectible: " + collider.name)
					_inventory.add_item(collider)
					Inventory.add_item(collider.duplicate())
					_prev_look = null # remove after taken
					_labelInteract.hide()
		else:
			#stop showing interact tooltip and disable outline
			_labelInteract.hide()
			if _prev_look != null and is_instance_valid(_prev_look):
				_prev_look.outline.hide()
	elif _prev_look != null and is_instance_valid(_prev_look):
		#disable outline of last seen object
		_prev_look.outline.hide()
		_prev_look = null

		#stop showing interact tooltip
		_labelInteract.hide()


func _input(event):
	# capture mouse movement
	if event is InputEventMouseMotion:
		_camera.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		# Prevent player from doing a purzelbaum
		_camera.rotation_degrees.x = clamp(_camera.rotation_degrees.x, -70, 70)


func _on_area_entered (area: Area):
	if area.is_in_group("Forbidden"):
		Logger.info("entering forbidden area!")
		_illegal_areas += 1
	elif area.is_in_group("Savehouse"):
		Logger.info("entering save area!")
		_save_areas += 1
	elif area.is_in_group("Workwork"):
		Logger.info("entering work area!")
		_work_areas += 1
	elif area.is_in_group("FactoryEntry"):
		Logger.info("entering factory")
		#IsInFactory = true
		#IsOutside = false
		get_tree().change_scene("res://Level/InFactory.tscn")
	elif area.is_in_group("TunnelEntry"):
		Logger.info("entering factory")
		#IsInFactory = false
		#IsOutside = false
		get_tree().change_scene("res://Level/Tunnel.tscn")
	# TODO: other entries
	elif area.is_in_group("OutsideEntry"):
		Logger.info("leaving factory")
		#IsInFactory = false
		#IsOutside = true
		get_tree().change_scene("res://Level/OutsideWorldReverse.tscn")
	elif area.is_in_group("LabyrinthEntry"):
		Logger.info("entering labyrinth")
		#IsInFactory = false
		#IsInLabyrinth = true
		get_tree().change_scene("res://Level/Labyrinth.tscn")


func _on_area_exited (area: Area):
	if area.is_in_group("Forbidden"):
		Logger.info("leaving forbidden area!")
		_illegal_areas -= 1
	elif area.is_in_group("Savehouse"):
		Logger.info("leaving save area!")
		_save_areas -= 1
	elif area.is_in_group("Workwork"):
		Logger.info("leaving work area!")
		_work_areas -= 1


func _on_respawn ():
	#Logger.info("respawning")
	# fade to black and restart scene
	_inventory.hide() # disable hud for the time of respawn animation
	
	if not IsInLabyrinth:
		_animationFadeOut.play("FadeOut")
		yield(_animationFadeOut, "animation_finished")
		_animationFadeOut.seek(0, true)

	Daytime._set_time(0)
	
	#Logger.info("save areas: " + String(_save_areas))
	if _save_areas < 1 and not IsInLabyrinth:
		Logger.info("move back to home")

		Inventory.clear()
		Pills._set_level(Pills.get_max())
		IsInFactory = false
		IsOutside = true
	
	if not IsInLabyrinth:
		get_tree().change_scene("res://Level/OutsideWorld.tscn")

	_inventory.show() # enable hud again


func _on_go_home ():
	if IsInFactory:
		showMessage("Jobs done! Time to go home", 4)


func _on_go_to_work ():
	if IsOutside:
		showMessage("Time to go to work", 4)


func _on_pill_level_low ():
	Logger.info("player received low pill")
	showMessage("Don't starve! Press 'F' to eat your food!", 4)


func _on_pill_level_very_low ():
	Logger.info("player received very low pill")
	showMessage("REALLY! You should eat your food!", 4)