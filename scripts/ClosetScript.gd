extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var anim = get_node("../../../AnimationPlayer")
onready var OpenSound = get_node("../../OpenSound")
onready var CloseSound = get_node("../../CloseSound")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#=	pass

func interact(player):
	if anim.is_playing(): return
	if anim.assigned_animation != "open": open()
	else: close()

func open():
	OpenSound.play()
	anim.play("open")
func close():
	CloseSound.play()
	anim.play("close")