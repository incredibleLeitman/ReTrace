extends KinematicBody

# export variables
export(bool) var invert_open
export(bool) var card_door
export(int) var door_lvl

var outline: MeshInstance

# const
const OPENING_SPEED = 150

# private members
var _startingRotY : float
var _isMoving = false
var _isOpening = false
var _degrees = 0
var _opening_dir = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	_startingRotY = global_transform.basis.get_euler().y
	outline = get_node("DoorMesh/Outline") as MeshInstance
	
	if invert_open:
		_opening_dir = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _isMoving:
		_door_move(delta)


# called by player to interact with this scene
func do_interact(var player):
	if card_door:
		if player.keycard_lvl >= door_lvl:
			_isMoving = true
			_isOpening = !_isOpening
		else:
			print("keycard level too low")
			player.showMessage("keycard level too low", 3)
	elif player.key_chain.has(door_lvl) or door_lvl == 0:
		_isMoving = true
		_isOpening = !_isOpening
	else:
		print("you don't have the right key")
		player.showMessage("you don't have the right key", 3)


# opens or closes the door
func _door_move(delta):
	if _isOpening:
		if _degrees < 105:
			_degrees += OPENING_SPEED * delta
		else:
			_degrees = 105
			_isMoving = false
	else:
		if _degrees > 0:
			_degrees -= OPENING_SPEED * delta
		else:
			_degrees = 0
			_isMoving = false

	rotate_y(_degrees * _opening_dir * PI/180 - global_transform.basis.get_euler().y + _startingRotY)
