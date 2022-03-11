extends KinematicBody

export(float) var Velocity = 1
export(int) var damage = 1
export(int) var push_force = 1
var Inertia = Vector3.ZERO
var friendly = false
var shooter
signal hit

class_name Bullet

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var forward_vec = -get_global_transform().basis.z
	move_and_slide(forward_vec * Velocity + Inertia)


func _on_Area_body_entered(body):
	var hs = body.get("HealthSystem")
	if hs != null:
		if friendly:
			if body.name != "Player":
				if hs.has_method("change_HP"): hs.change_HP(-damage)
				if body is KinematicBody:
					var push_vec = global_transform.origin - body.global_transform.origin
					body.move_and_slide(push_vec.normalized() * push_force)
		else: if body.name == "Player":
				hs.change_HP(-damage)
				var push_vec = global_transform.origin - body.global_transform.origin
				body.move_and_slide(push_vec.normalized() * push_force)
	if body != shooter: destory_self()
	
func destory_self():
	queue_free()
