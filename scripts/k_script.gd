extends Sprite3D

export var door_index = 0
export var destroy_on_use = true

onready var trigger = get_node('Area')
onready var SoundPlayer = get_node('/root/World/Player/AudioStreamPlayer')
onready var inv = get_node('../Player/Inventory')
onready var sound = load("res://sounds/misc/dsitemup.wav")
# Called when the node enters the scene tree for the first time.
func _ready():
	trigger.connect("body_entered",self,"trigger_enter")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func trigger_enter(collider):
	if collider.name != "Player": return
	SoundPlayer.stream = sound
	SoundPlayer.play()
	inv.k.append(door_index)
	
	queue_free()