extends ItemList

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var texture

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = get_item_icon(0)

func SetHearts(i):
	for n in range(get_item_count()):
		if n < i:
			set_item_disabled(n,false)
			set_item_icon(n,texture)
			
		else:
			set_item_icon(n,null)
			set_item_disabled(n,true)
