extends KinematicBody
enum modes {GROUND, HANGING, AIR}
enum moveTypes {move2D, move3D}
enum accels {AIR = 1, DEFAULT = 10, CAMERA = 40}
enum speeds {SLOW = 1, WALK = 4, RUN = 8}

const DRAG_GROUND := 0.7
const DRAG_AIR := 0.65
const JUMP_BUFFER := 0.08
const JUMP_POWER : int = 25
const GRAVITY := 2.8
const reachVector := Vector2(100, 0)
const hitVector := Vector2(16, 0)
const closeVector := Vector2(10, 0)

var moveType : int = moveTypes.move2D
var speed : int = speeds.WALK
var mode : int = modes.GROUND setget set_mode
var accel : int = accels.DEFAULT
var cam_accel : int = accels.CAMERA
var angular_velocity : int = 12
var pushForce : int = 11
var grabForce : int = 7
var timePressedHit := 0.0
var timePressedJump := 0.0
var timeLeftGround := 0.0
var fallTime := 0.0
var t := 0.0
var mouse_sense := 0.08
var isHanging := false
var isGrounded := false
var isAirborne := false
var isFalling := false
var wasGrounded := false
var velocity : Vector3
var snap = Vector3.UP
onready var head = $Head
onready var body = $body
onready var camPivot = $Head/CamPivot


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #hides the cursor
	body.set_as_toplevel(true) #makes the body's transforms independent from the kinematic body


func _input(event):
	#get mouse input for rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-45), deg2rad(45))


func _process(delta):
	#physics interpolation to reduce jitter on high refresh-rate monitors
	var fps = Engine.get_frames_per_second()
	if fps > Engine.iterations_per_second:
		camPivot.set_as_toplevel(true)
		camPivot.global_transform.origin = camPivot.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		camPivot.rotation.y = rotation.y
		camPivot.rotation.x = head.rotation.x
		body.global_transform.origin = body.global_transform.origin.linear_interpolate(global_transform.origin, cam_accel * delta)
	else:
		camPivot.set_as_toplevel(false)
		camPivot.global_transform = head.global_transform
		body.global_transform.origin = global_transform.origin


func _physics_process(delta):
	var inputVector = get_inputVector()
	var direction = (inputVector.x * transform.basis.x) + (inputVector.z * transform.basis.z)
	#check_raycast()
	check_collisions()
	set_velocity(direction, delta)
	apply_rotation(inputVector, direction, delta)
	check_mode()


func get_inputVector() -> Vector3:
	#returns the intended direction from the player's input
	var moveVector = Vector3()
	moveVector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	moveVector.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	return moveVector.normalized() if moveVector.length() > 1 else moveVector


func set_velocity(direction, delta):
	var drag : float
	if Input.is_action_pressed("run"): set_speed(speeds.RUN)
	else: set_speed(speeds.WALK)
	if isGrounded: drag = DRAG_GROUND
	else: drag = DRAG_AIR
	velocity += direction.normalized() * speed
	set_yVelocity()
	apply_drag(drag, delta)
	
	if moveType == moveTypes.move2D:
		if direction != Vector3.ZERO:
			if t < 1: t += 0.055
			velocity.x = velocity.linear_interpolate(direction * speed / 2, t * delta * 5).x
			velocity.z = velocity.linear_interpolate(direction * speed, t * delta * 10).z
		else:
			t = 0
			velocity.x = lerp(velocity.x, 0, 2)
			velocity.z = lerp(velocity.z, 0, 2)
	elif moveType == moveTypes.move3D: #set up tank controls later
		pass

	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, deg2rad(60))


func apply_drag(drag, delta):
	velocity.x *= pow(1 - drag, delta * 10)
	velocity.z *= pow(1 - drag, delta * 10)
	if velocity.x > -2 and velocity.x < 2: velocity.x = 0
	if velocity.z > -2 and velocity.z < 2: velocity.z = 0


func check_mode():
	if !isAirborne: isAirborne = wasGrounded and !isGrounded
	elif velocity.y > 0 and !isFalling and isAirborne:
		isFalling = true
		fallTime = get_cur_time()
	#if isGrounded: 
	#	if isAirborne: isAirborne = false
	#	if isFalling: isFalling = false
	wasGrounded = isGrounded
	if isGrounded: set_mode(modes.GROUND)
	if isAirborne: set_mode(modes.AIR)
	if isHanging: set_mode(modes.HANGING)



func check_raycast():
	if Input.is_action_pressed("click"):
		var directState = get_world().direct_space_state
		var collision = directState.intersect_ray(transform.origin, Vector3(0, 0, -20))
		if collision: print(collision.position)


func apply_rotation(_inputVector, direction, delta):
	if direction != Vector3.ZERO:
		body.rotation.y = lerp_angle(body.rotation.y, atan2(-direction.x, -direction.z), angular_velocity * delta)


func set_yVelocity():
	if isHanging:
		print("hanging")
		if Input.is_action_pressed("move_forward"): velocity = move_and_slide(Vector3(0,-speeds.SLOW,0),Vector3.UP)
		else: velocity.y = 0
	if !isGrounded and wasGrounded: 
		print("just jumped")
		timeLeftGround = get_cur_time()
	var pressedJump = Input.is_action_just_pressed("jump")
	var releasedJump = Input.is_action_just_released("jump")
	if releasedJump:
		if sign(velocity.y) == -1: velocity.y *= 0.4
		snap = Vector3.UP
		
	elif pressedJump:
		timePressedJump = get_cur_time()
		print("jump pressed")
		snap = Vector3.ZERO
		if isGrounded:
			velocity.y = JUMP_POWER
		elif get_cur_time() - timeLeftGround < JUMP_BUFFER:
			velocity.y = JUMP_POWER
		if isGrounded: velocity.y = JUMP_POWER
	else: if !isHanging: apply_gravity()
	#if isGrounded and velocity.y > 0: velocity.y = 0
	if !wasGrounded and isGrounded and ((get_cur_time() - timePressedJump) < JUMP_BUFFER):
		velocity.y = JUMP_POWER


func apply_gravity():
	var gravityResistance = get_floor_normal() if is_on_floor() else Vector3.UP
	velocity -= gravityResistance * GRAVITY


func check_collisions():
	isGrounded = is_on_floor()
	for index in get_slide_count():
			var collision = get_slide_collision(index)
			var collider = collision.collider
			if (collision.normal.z != 0 or collision.normal.x != 0):
					if Input.is_action_pressed("hit"): 
						print(collider.name)
						isHanging = true
					else: isHanging = false
			if collision.normal.y == -1: 
				if isAirborne: isAirborne = false
				if isFalling: isFalling = false

func set_mode(newMode):
	if mode == newMode: return
	mode = newMode
	#match mode:
	#	modes.AIR: print("mode: air")
	#	modes.GROUND: print("mode: ground")
	#	modes.HANGING: print("mode: hanging")


func set_speed(newSpeed):
	if speed == newSpeed: return
	speed = newSpeed


func get_cur_time() -> float:
	return OS.get_ticks_msec() / 1000.0
