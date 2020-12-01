extends StaticBody

#export variables
export(Color) var content_color

onready var _mesh = get_node("Mesh")
onready var lever = get_node("Lever")
onready var _col_shape = get_node("CollisionShape")

# constant variables
const NULL_COLOR = Color(0, 0, 0, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	#var material = SpatialMaterial.new()
	#_mesh.material_override = material
	#material.albedo_color = content_color
	#print(content_color)
	pass

func load_content_color():
	var material = SpatialMaterial.new()
	_mesh.material_override = material
	material.emission_enabled = true
	material.emission = content_color
	material.emission_energy = 0.5
	material.albedo_color = content_color

func update_content_color(var unused):
	if lever.is_on:
		_col_shape.disabled = false
	else:
		_col_shape.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
