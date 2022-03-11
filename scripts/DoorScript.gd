extends KinematicBody

export var door_index = 0
onready var inv = get_node('/root/World/Player/Inventory')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

onready var anim = get_node("AnimationPlayer")
onready var OpenSound = get_node("OpenSound")
onready var CloseSound = get_node("CloseSound")
var opened = false

func interact(player):
	if anim.is_playing(): return
	if opened == false: open(player)
	else: close(player)

func open(player):
	if anim.is_playing(): return
	if door_index != 0:
		if !inv.k.has(door_index): return
	OpenSound.play()
	var forward_vector =get_global_transform().basis.z
	var player_rel = player.get_global_transform().origin - get_global_transform().origin
	var res = forward_vector.dot(player_rel)
	if res > 0:
		anim.play("open_f")
	else: anim.play("open_b")
	opened = true
	
func close(player):
	if anim.is_playing(): return
	if door_index != 0:
		if !inv.k.has(door_index): return
	CloseSound.play()
	anim.play_backwards(anim.assigned_animation)
	opened = false