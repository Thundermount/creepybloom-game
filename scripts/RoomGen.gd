extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var index = 0
onready var RoomPrp = get_node('/root/World/RoomProperties')
# Called when the node enters the scene tree for the first time.
func _ready():
	#yield(get_tree().create_timer(0.01), "timeout")
	if get_node("../../").name == "Start":
		spawn_room()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var room
var old_dir
func spawn_room():
	randomize()
	if RoomPrp.Room_num < RoomPrp.Room_max:
		#room = RoomPrp.Rooms[randi()%RoomPrp.Rooms.size()-1].instance()
		#room = pick_forward()
		old_dir = RoomPrp.dir
		match RoomPrp.dir:
			0:	
				match randi()%2:
					0: pick_forward()
					1: pick_right()
					2: pick_left()
			-1:
				match randi()%4:
					0: pick_forward()
					1: pick_right()
					2: pick_left()
					3: pick_forward()
					4: pick_right()
					
			-2: 
				pick_right()
			1: 
				match randi()%4:
					0: pick_forward()
					1: pick_left()
					2: pick_right()
					3: pick_forward()
					4: pick_left()
			2: 
				pick_left()
			
		room.get_node("map/RoomSpawner").index = index+1
		add_child(room)
		
		#room.transform.origin = transform.origin
		#room.rotation = rotation
		RoomPrp.Room_num += 1
		yield(get_tree().create_timer(0.7), "timeout")
		if is_instance_valid(room):
			get_node("../../Area").queue_free()
			room.get_node("map/RoomSpawner").spawn_room()
		else: spawn_room()
		
	

func _on_Area_body_entered(body):
	if body.get_node("RoomSpawner"):
		if body.get_node("RoomSpawner").index - index > 1:
			if body.get_node("RoomSpawner").index > index:
				RoomPrp.dir = old_dir
				#body.free()
				body.get_node("../").queue_free()
				#yield(get_tree().create_timer(1.0), "timeout")
				RoomPrp.Room_num -= 1
				
				#spawn_room()

func pick_forward():
	room = RoomPrp.ForwardRooms[randi()%RoomPrp.ForwardRooms.size()-1].instance()
	#if (RoomPrp.dir != 0): RoomPrp.dir -= abs(RoomPrp.dir) / RoomPrp.dir
func pick_left():
	room = RoomPrp.LeftRooms[randi()%RoomPrp.LeftRooms.size()-1].instance()
	RoomPrp.dir -= 1
func pick_right():
	room = RoomPrp.RightRooms[randi()%RoomPrp.RightRooms.size()-1].instance()
	RoomPrp.dir += 1