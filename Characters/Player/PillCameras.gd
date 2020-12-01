extends Spatial


var screen_texture: ColorRect


func _ready():
	screen_texture = get_node("ScreenTextureView") as ColorRect
	assert(null != screen_texture)


func _process(delta: float) -> void:
	# The factor is 0 when the pill level is zero.
	# Between pill level 0 and 0.5, the factor scales between 0 and 1.
	var factor
	
	if Pills.get_normalized_level() < 0.5:
		factor = Pills.get_normalized_level() * 2.0
	else:
		factor = 1.0
		
	screen_texture.material.set_shader_param("mask_factor", factor)