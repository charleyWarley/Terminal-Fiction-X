extends KinematicBody
enum accels {AIR = 1, DEFAULT = 10, CAMERA = 40}
enum speeds {SLOW = 1, WALK = 4, RUN = 8}

const DRAG_GROUND := 0.7
const DRAG_AIR := 0.65
const JUMP_BUFFER := 0.08
const JUMP_POWER : int = 25
const GRAVITY := 2.8

var speed : int = speeds.SLOW
var t := 0.0
var accel : int = accels.DEFAULT
var angular_velocity : int = 12
var isGrounded = false
var isAirborne = false
var isFalling := false
var wasGrounded := false
var velocity : Vector3
var randomVector : Vector3
var snap = Vector3.UP
var slideTime = 0

onready var body = $body

func _ready():
	set_randomVector()
	
func _physics_process(delta):
	var direction = (randomVector.x * transform.basis.x) + (randomVector.z * transform.basis.z)
	set_velocity(direction, delta)
	apply_rotation(randomVector, delta)
	check_collisions()

func check_collisions():
	for index in get_slide_count():
			var collision = get_slide_collision(index)
			var collider = collision.collider
			if ((abs(collision.normal.normalized().z) >= 0.8) or (abs(collision.normal.normalized().x) >= 0.8)): set_randomVector()
			elif ((abs(collision.normal.normalized().z) >= 0.005) and (abs(collision.normal.normalized().x) >= 0.005)):
				slideTime += 1
				if slideTime > 1000: 
					slideTime = 0
					set_randomVector()
			if collision.normal.y == -1: 
				if isAirborne: isAirborne = false
				if isFalling: isFalling = false
	

func set_randomVector() -> void:
	print("direction randomized")
	randomize()
	var randomX = randi()%2
	if randomX == 0: randomX = -randi()%2
	else: randomX = randi()%2
	var randomZ = randi()%2
	if randomZ == 0: randomZ = -randi()%2
	else: randomZ = randi()%2
	randomVector = Vector3(randomX, 0, randomZ).normalized()
	if randomVector == Vector3.ZERO: set_randomVector()


func set_velocity(direction, delta):
	var drag : float
	if isGrounded: drag = DRAG_GROUND
	else: drag = DRAG_AIR
	velocity += direction.normalized() * speed
	var gravityResistance = get_floor_normal() if is_on_floor() else Vector3.UP
	velocity -= gravityResistance * GRAVITY
	apply_drag(drag, delta)
	
	if direction != Vector3.ZERO:
		if t < 1: t += 0.055
		velocity.x = velocity.linear_interpolate(direction * speed / 2, t * delta * 5).x
		velocity.z = velocity.linear_interpolate(direction * speed, t * delta * 10).z
	else:
		t = 0
		velocity.x = lerp(velocity.x, 0, 2)
		velocity.z = lerp(velocity.z, 0, 2)

	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, deg2rad(60))


func set_speed(newSpeed):
	if speed == newSpeed: return
	speed = newSpeed


func apply_drag(drag, delta):
	velocity.x *= pow(1 - drag, delta * 10)
	velocity.z *= pow(1 - drag, delta * 10)
	if velocity.x > -2 and velocity.x < 2: velocity.x = 0
	if velocity.z > -2 and velocity.z < 2: velocity.z = 0
 
func apply_rotation(direction, delta):
	if direction != Vector3.ZERO:
		body.set_as_toplevel(true)
		body.rotation.y = lerp_angle(body.rotation.y, atan2(-direction.x, -direction.z), angular_velocity * delta)
		body.set_as_toplevel(false)
