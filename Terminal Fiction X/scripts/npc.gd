extends KinematicBody


var velocity : Vector3
var speed = 10
var gravity = 2.8
var direction : Vector3

func get_direction():
	direction = Vector3(get_rand(), 0, get_rand()).rotated(Vector3.UP, speed).normalized()
	print(direction)

func get_rand():
	randomize()
	var rand = randi() % 2
	match rand:
		0: rand = -(randi() % 2)
		1: rand = randi() % 2
	print(rand)
	return rand


func _physics_process(delta):
	if direction == Vector3.ZERO: get_direction()
	velocity = direction * speed * delta
	velocity.y = -gravity
	velocity = move_and_slide_with_snap(velocity, Vector3(0,1,0), Vector3.UP, true)
