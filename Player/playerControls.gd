extends CharacterBody3D

@export_category("Player")
@export_range(1, 35, 1) var walk_speed: float = 10 # m/s
@export_range(1, 5, 0.05) var sprint_speed: float = 1.5 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 10.0, 0.1) var jump_height: float = 1 # m
#@export_range(0.1, 9.25, 0.05, "or_greater") var camera_sens: float = 3

var cam_accel = 40
var mouse_sense = 0.11
var snap

@onready var handArea = $Head/Camera3D/Hand



var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

@onready var head = $Head
@onready var camera = $Head/Camera3D


func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if Input.is_action_just_pressed("jump"): jumping = true
	if Input.is_action_just_pressed("exit"): get_tree().quit()
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func _process(delta):
	
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	#if Engine.get_frames_per_second() > Engine.physics_ticks_per_second:
	camera.set_as_top_level(true)
	camera.global_transform.origin = camera.global_transform.origin.lerp(head.global_transform.origin, cam_accel * delta)
	camera.rotation.y = rotation.y
	camera.rotation.x = head.rotation.x
		
	#else:
		#camera.set_as_top_level(false)
		#camera.global_transform = head.global_transform
		#pass
		
func _physics_process(delta):
	#get keyboard input
	#direction = Vector3.ZERO
	#var h_rot = global_transform.basis.get_euler().y
	#var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	#var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	move_and_slide()


func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var _forward: Vector3 = camera.transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	var sprint_modifier
	if (Input.is_action_pressed("sprint")):
		sprint_modifier = sprint_speed
	else:
		sprint_modifier = 1
	walk_vel = walk_vel.move_toward(walk_dir * walk_speed * sprint_modifier * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel
