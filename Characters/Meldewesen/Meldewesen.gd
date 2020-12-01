extends NPC


export(int) var _player_follow_pill_level = Pills.LEVELS.MEDIUM

onready var visibility_cone_mesh = get_node("Visibility/VisibilityCone")

const MAX_CMDS = 5			# maximum repeaded commands before Meldewesen gets piss
const CMD_DIFF_MS = 4000	# time in ms before new command
const VISIBILITY_CONE_ALPHA = 0.2

enum BEHAVIOR {
	NORMAL = 0,
	GO_WORK = 1,
	GO_HOME = 2,
	TAKE_PILLS = 3,
	DO_JOB = 4,
	ANGRY = 5
}
var _curMood			# current set behavior

var _voice_clips = {
	"go_to_work": preload("res://Resources/Audio/meldewesen-go-to-work.wav"),
	"go_home": preload("res://Resources/Audio/meldewesen-go-home.wav"),
	"take_pills": preload("res://Resources/Audio/meldewesen-eat-food.wav"),
	"do_job": preload("res://Resources/Audio/meldewesen-do-job.wav"),
	"stop": preload("res://Resources/Audio/meldewesen-stop.wav")
}

var _visibility: Area
var _interactArea: Area
var _audioPlayer: AudioStreamPlayer3D
var _playerRef

onready var _start_pos = transform.origin
onready var _start_rot: Vector3 = rotation_degrees

var _followingPlayer = false	# true if Meldewesen finds player "suspicios" and follows
var _huntingPlayer = false 		# active if the Meldewesen wants to "catch" the player
var _seeingPlayer = false		# as long as player is in visible range
var _lastSound = 0				# timestamp of last played message
var _countCmds = 0				# count of spoken commands -> after MAX_CMDS Meldewesen gets pissy


# test only
var _prev_target = null

func _ready():
	#Logger.set_logger_level(Logger.LOG_LEVEL_FINE)
	
	_audioPlayer = get_node("AudioStreamPlayer3D") as AudioStreamPlayer3D
	assert(null != _audioPlayer)
	
	_visibility = get_node("Visibility") as Area
	assert(null != _visibility)
	_visibility.connect("body_entered", self, "_on_body_entered_visibility")
	_visibility.connect("body_exited", self, "_on_body_exited_visibility")

	# setup collisions with player
	var _interactArea = get_node("InteractArea") as Area
	assert(null != _interactArea)
	_interactArea.connect("area_entered", self, "_on_area_entered")

	# TODO: does this implementation have to be that way?
	for player in get_tree().get_nodes_in_group("Player"):
		if player.is_class("KinematicBody"):
			_playerRef = player
			break
	assert(null != _playerRef)
	
	change_visibility_cone_color(Color.green)


func _process(_delta):
	# movement
	if current_target:
		if _prev_target != current_target:
			#Logger.info("current target: " + String(current_target))
			_prev_target = current_target

		# continue following player after illegal action or low pill level
		if _huntingPlayer or (_followingPlayer and Pills.get_round_level() <= _player_follow_pill_level):
			current_target = _playerRef.transform.origin
		# stop following player if pill level is high enough and player is not in an illegal area
		else:
			if _followingPlayer:
				Logger.info("player pill level ok and no illegal actions detected!")
				_followingPlayer = false
				current_target = _start_pos
			elif current_target == _start_pos and transform.origin.distance_to(current_target) < 0.1:
				Logger.info("the watch begins")
				current_target = null
				current_look_target = null
				rotation_degrees = _start_rot

	if _seeingPlayer:
		_set_behavior() # logic

		# audio
		if _audioPlayer.stream != null:
			var cur_time = OS.get_ticks_msec()
			if cur_time - _lastSound > CMD_DIFF_MS:
				#Logger.info("playing last command again")
				_audioPlayer.play()
				_lastSound = cur_time
				_countCmds += 1


func _on_area_entered (area: Area):
	if area.is_in_group("Player") and _huntingPlayer:
		Logger.info("caught player!")
		Daytime.emit_signal("respawn")


func change_visibility_cone_color(new_color: Color):
	if visibility_cone_mesh.get_surface_material(0).albedo_color != new_color:
		visibility_cone_mesh.get_surface_material(0).albedo_color = new_color
		visibility_cone_mesh.get_surface_material(0).albedo_color.a = VISIBILITY_CONE_ALPHA


func _load_sound ():
	match _curMood:
		BEHAVIOR.NORMAL:
			_audioPlayer.stream = null
		BEHAVIOR.GO_WORK:
			Logger.info("say go to work")
			_audioPlayer.stream = _voice_clips.go_to_work
		BEHAVIOR.GO_HOME:
			Logger.info("say go home")
			_audioPlayer.stream = _voice_clips.go_home
		BEHAVIOR.TAKE_PILLS:
			Logger.info("say take your pills")
			_audioPlayer.stream = _voice_clips.take_pills
		BEHAVIOR.DO_JOB:
			Logger.info("say do your job")
			_audioPlayer.stream = _voice_clips.do_job
		BEHAVIOR.ANGRY: 
			Logger.info("say stop!")
			_audioPlayer.stream = _voice_clips.stop


func _set_behavior ():
	if _huntingPlayer == false:
		var reason = null
		var daytime = Daytime.get_time()
		if _playerRef.IsHunted: # player is already marked by another Meldewesen
			reason = "player is haunted"
		elif _playerRef.is_in_illegalzone(): # player is in illegal area
			reason = "player is haunted in illegal area"
		elif Pills.get_round_level() == 0: # player has taken no pills in a while
			reason = "player's pill level is zero"
		elif _playerRef.IsOutside and daytime > Daytime.WORK_TIME and daytime < Daytime.SLEEP_TIME: # outside during WORK_TIME
			reason = "player outside during worktime"
		#elif _playerRef.IsInFactory and daytime < Daytime.WORK_TIME and daytime > Daytime.SLEEP_TIME: # at work after out of WORK_TIME
		# EDIT: too early at work is not an angry reason :p
		elif _playerRef.IsInFactory and daytime > Daytime.SLEEP_TIME + Daytime.TIGGER_TIME: # at work after out of WORK_TIME
			reason = "player in factory out of worktime"
			Logger.info("daytime: " + String(daytime) + " SLEEP_TIME: " + String(Daytime.SLEEP_TIME))
		elif _countCmds > MAX_CMDS: # after MAX_CMDS repeats of the same command
			reason = "player is seemingly not coorperativ"
		
		# mark player for all other Meldewesen if seen during illegal action
		if reason != null:
			Logger.info("catch player! reason: " + reason)
			_huntingPlayer = true
			_playerRef.IsHunted = true

	if _followingPlayer == false:
		# If the player didn't take enough pills lately, they're suspicious -> following
		if Pills.get_round_level() <= _player_follow_pill_level:
			Logger.info("The player's pill level is too low - following!")
			_followingPlayer = true

	if _huntingPlayer or _followingPlayer:
		current_target = _playerRef.transform.origin
		if _huntingPlayer:
			change_visibility_cone_color(Color.red)
		if _followingPlayer:
			change_visibility_cone_color(Color.yellow)
	else:
		change_visibility_cone_color(Color.green)

	var mood = BEHAVIOR.NORMAL
	var daytime = Daytime.get_time()
	if _playerRef.IsHunted:
		mood = BEHAVIOR.ANGRY
	# take your pills
	elif Pills.get_level() < _player_follow_pill_level:
		mood = BEHAVIOR.TAKE_PILLS
	# go home
	elif daytime > Daytime.SLEEP_TIME:
		mood = BEHAVIOR.GO_HOME
	# do your job
	elif _playerRef.is_in_workzone():
		_countCmds = 0 # hard block -> work is always good :D
		mood = BEHAVIOR.DO_JOB
	# go to work
	elif daytime < Daytime.WORK_TIME:
		mood = BEHAVIOR.GO_WORK

	if mood != _curMood:
		Logger.info("new mood: " + BEHAVIOR.keys()[mood] + " with cntcmd: " + String(_countCmds))
		_countCmds = 0
		_curMood = mood
		_load_sound()


func _on_body_entered_visibility (body: PhysicsBody):
	#Logger.trace("Meldewesen seeing %s" % [body])
	if body.is_in_group("Player"):
		Logger.info("Seeing player!")
		_seeingPlayer = true


func _on_body_exited_visibility(body: PhysicsBody):
	if body.is_in_group("Player"):
		Logger.info("Stopped seeing player!")
		_seeingPlayer = false
		_countCmds = 0
		if _huntingPlayer == false and _followingPlayer == false:
			change_visibility_cone_color(Color.green)
			# dirty quickfix: TODO: refactor
			if current_target != _start_pos:
				current_target = null
