extends Node

export (int) var Room_max = 30
var Room_num = 1
export (Array) var LeftRooms
export (Array) var RightRooms
export (Array) var ForwardRooms
var dir = 0

# МАССИВ ДЛЯ СЕТКИ: Сюда код будет мгновенно записывать координаты комнат
var registered_rooms = []

func _ready():
	randomize()
