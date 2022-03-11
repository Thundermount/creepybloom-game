extends OmniLight

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var energy = light_energy
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	light_energy = lerp(light_energy,rand_range(energy - 10, energy + 10),0.01)
	if light_energy < 0: light_energy = 0
