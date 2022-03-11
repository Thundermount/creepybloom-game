extends Node

export (int) var Room_max = 10 #максимальное число генерируемых комнат
var Room_num = 1 #текущее количество комнат включаяя начальную
export (Array) var LeftRooms
export (Array) var RightRooms
export (Array) var ForwardRooms
var dir = 0 #текущее направление поворота отрицательное налево положительное направо 0 прямо

func _ready():
	randomize()