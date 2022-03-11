extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(self.visible == true): self.set_text(String(Engine.get_frames_per_second()))

func _input(event):
	if Input.is_action_just_pressed("debug_dev"):
		self.visible = !self.visible