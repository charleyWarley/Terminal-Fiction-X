extends Spatial

var t = 0
var canLook = false
var mouseSensitivity = 0.05

export(NodePath) onready var target = get_node(target)
export(NodePath) onready var spring = get_node(spring)

func _input(event):
	if event.is_action_pressed("click"): canLook = true
	elif event.is_action_released("click"): canLook = false
	if event is InputEventMouseMotion and canLook:
		target.rotate_y(deg2rad(-event.relative.x * mouseSensitivity))
		spring.rotate_x(deg2rad(-event.relative.y * mouseSensitivity))
		target.wandPivot.rotate_x(deg2rad(-event.relative.y * mouseSensitivity))
		spring.rotation.x = clamp(spring.rotation.x, deg2rad(-75), deg2rad(75))
		target.wandPivot.rotation.x = clamp(target.wandPivot.rotation.x, deg2rad(-75), deg2rad(75))

