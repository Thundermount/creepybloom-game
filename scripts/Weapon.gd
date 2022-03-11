extends Node

class_name Weapon

export var Attack_speed = 1 #Default attack speed of the weapon given to the player
export var attackSpeedMultiplier = 0.1
var canShoot = true

enum CreateAt{
	BeginAnimation,
	MiddleAnimation,
	EndAnimation
}
export(CreateAt) var CreateBulletAt = CreateAt.BeginAnimation

export(Vector3) var Offset = Vector3()
onready var Anim_player = get_node("AnimationPlayer")
onready var Player = get_node("../../../")
onready var camera = get_node("../../")
export(PackedScene) onready var bullet_scene
export(Vector3) onready var bullet_instance = Vector3(0,0,0.3)
var activated = true
var shooting = false

func _process(delta):
	if not activated: return
	if Input.is_action_pressed("fire"):
		if !Anim_player.is_playing():
			Attack()
	if Input.is_action_just_released("fire"):
		StopAttack()
	
	if shooting:
		if CreateBulletAt == CreateAt.MiddleAnimation:
			if Anim_player.current_animation_position >= Anim_player.current_animation_length / 2.0:
				shoot_bullet()
				shooting = false
		elif CreateBulletAt == CreateAt.EndAnimation:
			if Anim_player.current_animation_position == Anim_player.current_animation_length:
				shoot_bullet()
				shooting = false


func _ready():
	Activate(false)
	Attack_speed = Player.HealthSystem.Attack_speed

func fire_animation():
	Anim_player.play("fire")

func redefine_animation_speed():
	Attack_speed = Player.HealthSystem.Attack_speed
	Anim_player.playback_speed = Attack_speed * attackSpeedMultiplier

func Attack():
	redefine_animation_speed()
	fire_animation()
	#elif Anim_player.current_animation_position != Anim_player.current_animation_length:
		#Anim_player.play("fire")
	if CreateBulletAt != CreateAt.BeginAnimation: shooting = true
	else:
		shoot_bullet()

func StopAttack():
	pass #Anim_player.play_backwards("fire")

func instance_bullet():
	return bullet_scene.instance()

func shoot_bullet():
	if !canShoot: return
	
	var bullet = instance_bullet()
	bullet.friendly = true
	bullet.shooter = Player
	get_node("/root/World").add_child(bullet)
	bullet.global_transform.origin = camera.global_transform.origin -camera.get_global_transform().basis * bullet_instance
	bullet.rotation = camera.rotation + Player.rotation
	bullet.Inertia = Player.GetVelocity() * 10
	
func Activate(act):
	self.visible = act
	activated = act

