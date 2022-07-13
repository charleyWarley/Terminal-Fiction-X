extends Spatial

var isMouseVisible = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event.is_action_released("hide_mouse"): 
		isMouseVisible = !isMouseVisible
	if isMouseVisible == true: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
