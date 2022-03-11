extends Weapon

onready var timer = get_node("Timer")

func _ready():
	Activate(false)
	Attack_speed = Player.HealthSystem.Attack_speed
	timer.wait_time = 1 / (Attack_speed * attackSpeedMultiplier) 
	

func StopAttack():
	Anim_player.play_backwards("fire")
	
func fire_animation():
	if Anim_player.current_animation_position != Anim_player.current_animation_length:
		Anim_player.play("fire")

func redefine_animation_speed():
	pass

func instance_bullet():
	canShoot = false
	timer.start()
	
	return bullet_scene.instance()	

func _on_Timer_timeout():
	canShoot = true
