extends Viewport


func _ready():
	get_tree().get_root().connect("size_changed", self, "adapt_resolution")
	
	adapt_resolution()


func adapt_resolution():
	size = OS.window_size
