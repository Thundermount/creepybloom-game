tool
extends Spatial

export(Resource) var Item

onready var player = get_node("/root/World/Player/")
onready var spr = get_node("Sprite3D") as Sprite3D
onready var SoundPlayer = get_node('/root/World/Player/AudioStreamPlayer')
onready var sound = load("res://sounds/misc/dsitemup.wav")
export(bool) var IsWeapon = false
export(PackedScene) var WeaponToGive

# Called when the node enters the scene tree for the first time.
func _ready():
	spr.texture = Item.sprite
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		if spr != null:
			spr.texture = Item.sprite


func _on_Area_body_entered(body):
	if body == player:
		give_item()
		
		if IsWeapon:
			var WeaponSwitcher = body.get_node('Camera/WeaponSwitcher')
			var weapon = WeaponToGive.instance()
			var w = WeaponSwitcher.get_node(weapon.name)
			if (w != null): w.free()
			WeaponSwitcher.add_child(weapon)
			weapon.global_transform.origin = WeaponSwitcher.global_transform.origin + weapon.Offset
			weapon.rotation = WeaponSwitcher.rotation
		
		spr.queue_free()
		get_node("Area").queue_free()
		SoundPlayer.stream = sound
		SoundPlayer.play()

func give_item():
	player.MAX_SPEED += 0.1 * Item.speed
	player.JUMP_SPEED += 0.1 * Item.jump
	player.HealthSystem.change_HP(Item.HP)
	player.HealthSystem.Attack_speed += Item.attack_speed
	player.HealthSystem.damage += Item.damage