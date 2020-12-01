extends Control

var _container: GridContainer
var _labelPillLevel: Label
var _pillLevel: TextureProgress
var _labelDayTime: Label
var _dayTime: ProgressBar
var _dayTimeVisual: TextureRect

onready var _keyTexture = preload("res://Resources/Models/key/key.png")
var _cardTexture = {
	1: preload("res://Resources/Models/keycard/lvl1_keycard.png"),
	2: preload("res://Resources/Models/keycard/lvl2_keycard.png")
}

onready var _pillFill = preload("res://Resources/Textures/pillLevel_fill.png")
onready var _pillDanger = preload("res://Resources/Textures/pillLevel_danger.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	_container = get_node("InventoryContainer")
	_labelPillLevel = get_node("PillLevel")
	_pillLevel = get_node("PillProgress")
	_labelDayTime = get_node("DayTime")
	_dayTime = get_node("DayTimeProgress")
	_dayTimeVisual = get_node("DayTimeVisual")
	
	# TODO: may use global values in Inspector?
	_pillLevel.max_value = Pills.get_max()
	_dayTime.max_value = Daytime.get_max()
	
	for object in Inventory.get_items():
		add_item(object)


func add_item (object):
	Logger.info("Adding item \"" + object.name + "\" with class \"" + String(object.get_class()) + "\" to inventory")
	var texture
	if object is Key:
		Logger.info("key")
		texture = _keyTexture
	elif object is Keycard:
		Logger.info("keycard")
		var lvl = (object as Keycard).card_lvl
		if _cardTexture.has(lvl) == false:
			Logger.info("no keycard model for lvl: " + String(lvl))
			return

		texture = _cardTexture[lvl]
	else:
		Logger.info("no texture found for: " + object.name)
		return

	var rect = TextureRect.new()
	rect.texture = texture
	_container.add_child(rect)

func _process(_delta):
	# pill level
	var val = Pills.get_level()
	_labelPillLevel.text = "curLevel: " + String(val)
	_pillLevel.value = val
	if val < Pills.LEVELS.MEDIUM:
		_pillLevel.set_progress_texture(_pillDanger)
	elif _pillLevel.get_progress_texture() != _pillFill:
		_pillLevel.set_progress_texture(_pillFill)
	
	# day time
	val = int(Daytime.get_time())
	#_labelDayTime.text = "dayTime: " + String(val) + " - %02d:%02d" % [val/60%24, val%60]
	_dayTime.value = val
	_dayTimeVisual.rect_rotation = ((val/_dayTime.max_value) * 180) - 90
	