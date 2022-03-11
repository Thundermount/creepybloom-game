extends RigidBody

onready var player = get_node("../Player")

export var VISION_ANGLE = 360
export var VISION_LIMIT = 10
export var Speed = 1
export(Resource) var HealthSystem

onready var collider = get_node("CollisionShape")

var dir = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	HealthSystem.connect("die",self,"die")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	add_central_force(dir.normalized() * Speed)
	
	

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

func _on_Timer_timeout():
	if has_found():
		dir = player.transform.origin - transform.origin
	else: dir = Vector3()
	
func die():
	queue_free()

func _on_Area_body_entered(body):
	if body.name == "Player":
		body.HealthSystem.change_HP(-HealthSystem.damage)
