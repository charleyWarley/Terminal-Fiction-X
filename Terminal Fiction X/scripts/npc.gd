extends KinematicBody


var velocity : Vector3
var speed = 1
var GRAVITY = 6.8
onready var direction : Vector3
onready var body = get_node("body")


func apply_rotation(delta):
	if direction != Vector3.ZERO:
		body.set_as_toplevel(true)
		body.rotation.y = lerp_angle(body.rotation.y, atan2(-direction.x, -direction.z), speed * delta)
		body.set_as_toplevel(false)
		
		
func set_direction():
	direction = Vector3(Global.get_rand(), 0, Global.get_rand()).normalized()

func _ready():
	set_direction()
	
	
func _physics_process(delta):
	apply_rotation(delta)
	velocity = direction * speed * delta
	if !is_on_floor(): velocity.y = -GRAVITY
	var collision = move_and_collide(velocity)
	if collision: if abs(collision.normal.z) >= 0.9 or abs(collision.normal.x) >= 0.9: set_direction()
	velocity = move_and_slide_with_snap(velocity, Vector3(0,1,0), Vector3.UP, true)
