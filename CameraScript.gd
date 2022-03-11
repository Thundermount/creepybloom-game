extends Camera

export(Curve) var Camera_Sway


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
var b = 0
func _process(delta):
	b += 0.1 * delta
	if b >= 1.0: b = 0
	
	