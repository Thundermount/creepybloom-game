tool
extends Spatial

export(Array) var Sprites
export(int) var ID
export(bool) var Random_Item = false

onready var player = get_node("/root/World/Player/")
onready var spr = get_node("Sprite3D") as Sprite3D
onready var SoundPlayer = get_node('/root/World/Player/AudioStreamPlayer')
onready var sound = load("res://sounds/misc/dsitemup.wav")

# По идее предметы лучше делать через Resource см. Item.gd
# Однако при такой системе не совсем понятно где прописывать код на изменение характеристик игрока
# Также нужно затрачивать дополнительно время на более сложную систему инвентаря
# Также нет никаких плюсов хранить в переменной предметы влияющие только на характеристики игрока

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if Random_Item == true:
		ID = randi() % Sprites.size()
	spr.texture = Sprites[ID]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:	spr.texture = Sprites[ID]


func _on_Area_body_entered(body):
	if body == player:
		give_item()
		spr.queue_free()
		get_node("Area").queue_free()
		SoundPlayer.stream = sound
		SoundPlayer.play()

func give_item():
	match ID:
		0: pass