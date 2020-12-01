extends Spatial

#const
const LONGITUDE: int = -90 # we are on equator

const SUNRISE: Color = Color("ffdb00")
const SUNSET: Color = Color("ffdb00")
const STANDARD_SKY_TOP: Color = Color("a5d6f1") #godots standard sky top color
const SUNRISE_DEGREE: int = 15 #until this degree is sunset color
const RISE_INTERPOL: int = SUNRISE_DEGREE + 15 #until this degree, sunrise interpolates to day
const SUNSET_DEGREE: int = 170 #from this degree on is sunset color
const SET_INTERPOL: int = SUNSET_DEGREE - 15 #until this degree, day interpolates to sunset


#private members
var _worldEnvironment: WorldEnvironment
var _light: DirectionalLight

var _max: float #max Daytime
var _currentTime: float

var _degree: float #current degrees of sun & light  ((currentTime/maxTime) * 180)

#var _standardSkyHorizon: Color = Color("d6eafa") #godots standard sky horizon color
var _setSkyColor: Color #for setting current skycolor


# Called when the node enters the scene tree for the first time.
func _ready():
	#assign children
	_worldEnvironment = get_node("WorldEnvironment")
	assert(null != _worldEnvironment)
	
	_light = get_node("DirectionalLight")
	assert(null != _light)
	
	#set values
	_worldEnvironment.environment.background_sky.sun_longitude = LONGITUDE
	
	#get values (from the other side - adele)
	_max = Daytime.get_max()


func _process(_delta):
	_currentTime = Daytime.get_time()
	_degree = 20 + (_currentTime/_max) * 140
	_sun_position()
	_light_rotation()
	_sky_light()

#update sun position
func _sun_position():
	_worldEnvironment.environment.background_sky.sun_latitude = _degree
	
#update light position to sun position
func _light_rotation():
	_light.rotation_degrees = Vector3(-(_degree), LONGITUDE, 0)
	
#set light color depending on daytime
func _sky_light():
	var new_light_energy = 0.2
	
	if _degree <= SUNRISE_DEGREE:
		#_worldEnvironment.environment.background_sky.sky_curve = 1
		_setSkyColor = SUNRISE
	elif _degree > SUNRISE_DEGREE and _degree < RISE_INTERPOL: #interpolate colors from sunrise sky to daytime sky
		_setSkyColor = SUNRISE.linear_interpolate(STANDARD_SKY_TOP, ((_degree-SUNRISE_DEGREE)/(RISE_INTERPOL-SUNRISE_DEGREE)))
		new_light_energy = 0.2 + inverse_lerp(SUNRISE_DEGREE, RISE_INTERPOL, _degree) * 0.8
	elif _degree >= RISE_INTERPOL and _degree <= SET_INTERPOL:
		#_worldEnvironment.environment.background_sky.sky_curve = 0.09
		_setSkyColor = STANDARD_SKY_TOP
		new_light_energy = 1.0
	elif _degree > SET_INTERPOL and _degree < SUNSET_DEGREE: #interpolate colors from daytime sky to sunset sky
		_setSkyColor = STANDARD_SKY_TOP.linear_interpolate(SUNSET, ((_degree-SET_INTERPOL)/(SUNSET_DEGREE-SET_INTERPOL)))
		new_light_energy = 0.2 + (1.0 - inverse_lerp(SET_INTERPOL, SUNSET_DEGREE, _degree)) * 0.8
	elif _degree >= SUNSET_DEGREE:
		_setSkyColor = SUNSET
	
	_worldEnvironment.environment.background_sky.sky_horizon_color = _setSkyColor
	_light.light_energy = new_light_energy
	_worldEnvironment.environment.ambient_light_energy = 0.2 + 0.3 * new_light_energy