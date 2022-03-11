extends KinematicBody

class_name Player

var input_movement_vector = Vector3()
var dir = Vector3()
var vel = Vector3()
const GRAVITY = 4
var MAX_SPEED = 1.7
const ACCEL = 40
const DEACCEL= 40
var JUMP_SPEED = 1.7
const SWAY_SPEED = 1
const MOUSE_SENSITIVITY = 0.002
const DRAG_MAX_DISTANCE = 1.2
const DRAG_MIN_DISTANCE = 0.2
const DRAG_POWER = 10
var DRAG_DISTANCE = 0.7
var disable_mouse = false
var disable_movement = false
export(Curve) var Camera_Sway
export(Resource) var HealthSystem
onready var ActionRay = get_node("Camera/ActionRay")
var camera
var cam_xform
# variables for holding objects
var hold = null
var hold_collision = false
var Velocity
var canInteract = true
export (int, 0, 200) var push = 1
export(NodePath) onready var Hand = get_node(Hand)
onready var HeartShapedObjects = get_node("ui/PlayerStats/HeartShapedObjects")

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("Camera")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	HealthSystem.connect("die",self,"die")
	HealthSystem.connect("HP_changed",self,"HP_changed")
	Update_HeartShapedObjects()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func GetVelocity():
	return Velocity
onready var old_pos = transform.origin
onready var new_pos = old_pos
func SetVelocity():
	new_pos = transform.origin
	if new_pos != old_pos:
		Velocity = (new_pos - old_pos)
		old_pos = new_pos

func die():
	#Create a death screen later
	HealthSystem.set_HP(3)
	get_tree().reload_current_scene()

func HP_changed():
	Update_HeartShapedObjects()

func Update_HeartShapedObjects():
	HeartShapedObjects.SetHearts(HealthSystem.HP)

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
	if input_movement_vector != Vector3() && is_on_floor(): camera_sway(delta)
	dir = -get_global_transform().basis.z * input_movement_vector.y + get_global_transform().basis.x * input_movement_vector.x
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			vel.y = JUMP_SPEED
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	dir.y = 0
	dir = dir.normalized()
	
	vel.y -= delta * GRAVITY
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir
	target *= MAX_SPEED
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0),false, 4, PI/4, false)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.has_method("apply_central_impulse"):
			if collision.collider == hold:
				collision.collider.apply_central_impulse(-collision.normal * push * 4)
				hold_collision = true
				hold = null
				action_release()
				DRAG_DISTANCE = 1.7
			else:
				collision.collider.apply_central_impulse(-collision.normal * push)
				
			#collision.collider.apply_central_impulse(-collision.normal * vel.length() * push)
	if !hold: Hand.visible = ActionRay.is_colliding()
	else: Hand.visible = false
	if Input.is_action_pressed("action"): action()
	SetVelocity()
	
func _input(event):
	disable_mouse = Input.is_action_pressed("rotate")
	if event is InputEventMouseMotion && Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		if !disable_mouse:
			rotate_y(-MOUSE_SENSITIVITY * event.relative.x)
			camera.rotate_x(-MOUSE_SENSITIVITY * event.relative.y)
			var cam_rot = camera.rotation_degrees.x
			camera.rotation_degrees.x = clamp(cam_rot,-89,89)
		if Input.is_action_pressed("rotate") && hold:
			hold.angular_velocity = camera.global_transform.basis.x * event.relative.y + Vector3.UP * event.relative.x
	if Input.is_action_just_released("action"): action_release()
	if hold:
		if Input.is_action_pressed("push_object"):
			DRAG_DISTANCE += 0.1
			DRAG_DISTANCE = clamp(DRAG_DISTANCE,DRAG_MIN_DISTANCE,DRAG_MAX_DISTANCE)
		if Input.is_action_pressed("drag_object"):
			DRAG_DISTANCE -= 0.1
			DRAG_DISTANCE = clamp(DRAG_DISTANCE,DRAG_MIN_DISTANCE,DRAG_MAX_DISTANCE)


var sway_i = 0.0
func camera_sway(delta):
	camera.transform.origin.y = Camera_Sway.interpolate(sway_i)*0.317
	sway_i+=SWAY_SPEED * delta
	if sway_i > 1.0: sway_i = 0

func action():
	if !canInteract: return
	if ActionRay.is_colliding() && hold == null:
		var collider = ActionRay.get_collider()
		if collider.has_method("open"):
			door_interaction(collider)
		else:
			hold = collider
	hold_object()
		
func action_release():
	if hold != null:
		# turns collision with player back hold.set_collision_layer_bit(0,true)
		pass
	hold = null
	DRAG_DISTANCE = 0.7
	yield(get_tree().create_timer(1.0), "timeout")
	hold_collision = false
func hold_object():
	if hold == null || hold_collision: return
	# disables collision with player hold.set_collision_layer_bit(0,false)
	hold.linear_velocity=(-camera.global_transform.basis.z * DRAG_DISTANCE + camera.global_transform.origin - hold.transform.origin)*DRAG_POWER
	if abs(hold.transform.origin.length() - camera.global_transform.origin.length()) > DRAG_MAX_DISTANCE: action_release()
	if (!Input.is_action_pressed("rotate") && hold != null):
		hold.angular_velocity = Vector3.ZERO
		
func door_interaction(door):
	door.interact(self)