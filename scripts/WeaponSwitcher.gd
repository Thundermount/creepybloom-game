extends Node

var active_weapon = 0
var weaponSlots = [ KEY_1, KEY_2, KEY_3, KEY_4 ]
export(bool) var DisableInteractionOnWeaponUse = true
onready var player = get_node("../../")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _input(event):
    if (event is InputEventKey):
					for i in range(weaponSlots.size()):
						if event.scancode == weaponSlots[i]:
							get_weapon(i + 1)
		
func get_weapon(index):
	var wpn = get_node(str(index))
	var active = get_node(str(active_weapon))
	if active != null:
		active.Activate(false)
		if DisableInteractionOnWeaponUse && wpn == null:
			player.canInteract = true
	if wpn != null:
		wpn.Activate(true)
		active_weapon = index
		if DisableInteractionOnWeaponUse:
			player.canInteract = false