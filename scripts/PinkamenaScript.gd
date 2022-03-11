extends KinematicBody

var path = []
var path_node = 0
var speed
const GRAVITY = 4

enum {
	IDLE,
	PATROLLING,
	SEARCHING,
	CHASING	
}
export var state = IDLE
export var VISION_ANGLE = 90
export var VISION_LIMIT = 2
var patrolling_node = 0
var patrol_inverse = false

onready var player = get_node("../Player")
onready var nav = get_node("../Navigation") as Navigation
onready var anim = get_node("Pinkamena/AnimationPlayer") as AnimationPlayer
onready var rayforward = get_node("RayForward")

var velocity
var target

onready var search_delay = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	search_delay.wait_time = 4
	search_delay.connect("timeout",self,"stop_searching")
	search_delay.one_shot = true
	add_child(search_delay)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if state == PATROLLING:
		var vec = transform.origin
		vec.y = 0
		if target != null:
			var targ = target
			targ.y = 0
			#print_debug((targ - vec).length())
			if (targ - vec).length() < 0.1:
				point_reached()
			
		
	
	if path_node < path.size():
		var dir = (path[path_node] - transform.origin)
		dir.y = 0
		if state == CHASING: speed = player.MAX_SPEED + 0.01
		else: speed = 1.0
		#rotation = Vector3(0, transform.origin.normalized().angle_to(dir.normalized()),0)
		self.look_at(lerp(-get_global_transform().basis.z+transform.origin,-dir +transform.origin,0.1),Vector3(0,1,0))
		anim.play("WalkAnim")
		dir.y -= delta * GRAVITY
		if dir.length() < 0.1:
			path_node+= 1
		else:
			move_and_slide(dir.normalized() * speed)

func has_found():
	var space = get_world().get_direct_space_state()
	var player_vec = player.transform.origin - transform.origin
	if abs(player_vec.length()) < VISION_LIMIT:
		var angle = rad2deg(get_global_transform().basis.z.angle_to(player_vec))
		if angle < VISION_ANGLE:
			var result = space.intersect_ray( transform.origin, player.transform.origin )
			if result.values()[3] == player:
				return true
	return false

func begin_patrol():
	if state != PATROLLING:
		#yield(get_tree().create_timer(4.0), "timeout")
		state = PATROLLING
		patrolling_node = 0
		point_reached()

func update_path(target):
	path = nav.get_simple_path(transform.origin, target)
	if path == null: point_reached()
	path_node = 0

func stop_searching():
	if state != IDLE && !has_found(): begin_patrol()

func _on_Timer_timeout():
	velocity_check()
	if has_found():
		state = CHASING
	else:
		if search_delay.is_stopped(): search_delay.start()
		
	if state == CHASING: update_path(player.transform.origin)
	if state == PATROLLING:
		if target != null:
			if rayforward.is_colliding():
				var coll = rayforward.get_collider()
				if coll.get_class() == "StaticBody" || coll.get_class() == "KinematicBody":
					if coll != player && coll != self:
						point_reached()
			if velocity.length() == 0:
				point_reached()

func point_reached():
	anim.play("Idle")
	yield(get_tree().create_timer(1.0), "timeout")
	var vec = nav.get_closest_point(patrol())
	if vec == null: point_reached()
	vec.y = 0
	target = vec
	update_path(target)

func patrol():
	var radius = 4.0
	randomize()
	var x = rand_range(-radius, radius)
	randomize()
	var y = rand_range(-radius,radius)
	var vec = Vector3(x,0,y) + transform.origin
	
	return vec
	
	#patrol()

var old_pos = transform.origin
var new_pos
func velocity_check():
	new_pos = transform.origin
	velocity = new_pos - old_pos
	old_pos = new_pos