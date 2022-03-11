extends KinematicBody

var input_movement_vector = Vector3()
var dir = Vector3()
var vel = Vector3()
const GRAVITY = 0
const MAX_SPEED = 4
const ACCEL = 40
const DEACCEL= 40
const JUMP_SPEED = 1.7
const SWAY_SPEED = 1
const MOUSE_SENSITIVITY = 0.002
const DRAG_MAX_DISTANCE = 1.2
const DRAG_MIN_DISTANCE = 0.2
const DRAG_POWER = 10
var DRAG_DISTANCE = 0.7
var disable_mouse = false
var disable_movement = false
var camera
var cam_xform
var Speed_multipl = 1
# variables for holding objects

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("Camera")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	if disable_movement: return
	if Input.is_action_pressed("forward"):
		input_movement_vector.y += 1
	else:
		if Input.is_action_pressed("backwards"):
			input_movement_vector.y -= 1
		else: input_movement_vector.y = 0
	if Input.is_action_pressed("left"):
		input_movement_vector.x -= 1
	else:
		if Input.is_action_pressed("right"):
			input_movement_vector.x += 1
		else:
			input_movement_vector.x = 0

	input_movement_vector = input_movement_vector.normalized()
	
	dir = (-camera.get_global_transform().basis.z * input_movement_vector.y + camera.get_global_transform().basis.x * input_movement_vector.x)
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			vel.y = JUMP_SPEED
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#dir.y = 0
	dir = dir.normalized()
	
	vel.y -= delta * GRAVITY
	
	var hvel = vel
	#hvel.y = 0
	
	var target = dir
	target *= MAX_SPEED
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	if Input.is_key_pressed(KEY_SHIFT): Speed_multipl = 2
	else: Speed_multipl = 1
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel = hvel
	vel = move_and_slide(vel * Speed_multipl, Vector3(0, 1, 0),false, 4, PI/4, false)
				
			#collision.collider.apply_central_impulse(-collision.normal * vel.length() * push)
	
func _input(event):
	if event is InputEventMouseMotion && Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		if !disable_mouse:
			rotate_y(-MOUSE_SENSITIVITY * event.relative.x)
			camera.rotate_x(-MOUSE_SENSITIVITY * event.relative.y)
			var cam_rot = camera.rotation_degrees.x
			camera.rotation_degrees.x = clamp(cam_rot,-89,89)