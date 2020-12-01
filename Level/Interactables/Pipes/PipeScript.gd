extends Spatial

# export variables
export(NodePath) var mesh_path
export(NodePath) var color_cast_left
export(NodePath) var color_cast_up
export(bool) var can_turn
export(bool) var is_turned
export(int) var x_rot
export(int) var y_rot
export(int) var z_rot
export(Color) var content_color

onready var outline = get_node("Mesh/Outline") as MeshInstance
onready var fork_material = preload("res://Materials/Pipe_Dream.tres")

# signals
signal flow_changed

# constant variables
const NULL_COLOR = Color(0, 0, 0, 1)
const LIGHT_COLOR = Color(1, 1, 1, 1)

# private variables
var _left_cast : RayCast
var _up_cast : RayCast
var _left_color : Color
var _up_color : Color
var _mesh : MeshInstance


func _ready():
	_left_cast = get_node(color_cast_left) as RayCast
	_up_cast = get_node(color_cast_up) as RayCast
	_mesh = get_node(mesh_path) as MeshInstance

func do_interact(var player):
	if(is_turned):
		rotate_x(x_rot * PI/180)
		rotate_y(y_rot * PI/180)
		rotate_z(z_rot * PI/180)
		is_turned = false
	else:
		rotate_x(-x_rot * PI/180)
		rotate_y(-y_rot * PI/180)
		rotate_z(-z_rot * PI/180)
		is_turned = true
	emit_signal("flow_changed")


func _get_color_from_cast(ray_cast : RayCast):
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider.is_in_group("Pipes"):
			var new_color = collider.content_color
			if new_color != null:
				return new_color


func _blend_colors(var col1, var col2, var _all_colors: Array):
	var cols_of_1 = 2.0
	var cols_of_2 = 2.0
	for c in _all_colors:
		if col1 == c:
			cols_of_1 = 1.0
		elif col2 == c:
			cols_of_2 = 1.0
	var mix_pcent = cols_of_2/(cols_of_1 + cols_of_2)
	var mix_col = col1.linear_interpolate(col2, mix_pcent)
	return mix_col


func update_content_color(var _all_colors: Array):
	_left_color = NULL_COLOR
	_up_color = NULL_COLOR
	
	if _left_cast != null:
		var new_color = _get_color_from_cast(_left_cast)
		if new_color != null:
			_left_color = new_color
	if _up_cast != null:
		var new_color2 = _get_color_from_cast(_up_cast)
		if new_color2 != null:
			_up_color = new_color2
	
	if _left_color != NULL_COLOR and _up_color != NULL_COLOR:
		var mix = _blend_colors(_left_color, _up_color, _all_colors)
		content_color = mix
	elif _left_color != NULL_COLOR:
		content_color = _left_color
	elif _up_color != NULL_COLOR:
		content_color = _up_color
	else:
		content_color = NULL_COLOR
	
	if _mesh != null:
		var material = SpatialMaterial.new()
		
		if content_color != NULL_COLOR:
			if can_turn:
				var mix = content_color.linear_interpolate(LIGHT_COLOR, 0.5)
				material.albedo_color = mix
			else:
				material.albedo_color = content_color
			
			material.emission_enabled = true
			material.emission = content_color
			
			#print(get_name())
		elif can_turn:
			material = fork_material

		_mesh.material_override = material
