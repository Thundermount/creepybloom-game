extends Spatial

var index = 0
var RoomPrp = null # Ссылку передаст предыдущий спавнер
var room
var old_dir

# СЧЁТЧИК ТУПИКОВ: Считает, сколько раз подряд в этой точке комнаты удалялись из-за коллизий
var fail_attempts = 0

func _ready():
	# Блок ready выполнится ТОЛЬКО для самой первой стартовой платформы уровня
	if get_node_or_null("../../") and get_node("../../").name == "Start":
		# Даем один кадр, чтобы сцена World и узел RoomProperties точно загрузились
		yield(get_tree(), "idle_frame")
		
		# Ищем настройки на уровне
		if get_tree() and get_tree().current_scene:
			RoomPrp = get_tree().current_scene.find_node("RoomProperties", true, false)
			
		if not RoomPrp:
			RoomPrp = get_node_or_null('/root/World/RoomProperties')
			
		if RoomPrp:
			print("[ГЕНЕРАТОР] Стартовый узел готов. Начинаем спавн уровня...")
			spawn_room()
		else:
			print("[КРИТИЧЕСКАЯ ОШИБКА] Не найден узел RoomProperties на сцене!")

func spawn_room():
	if not RoomPrp:
		if get_tree() and get_tree().current_scene:
			RoomPrp = get_tree().current_scene.find_node("RoomProperties", true, false)
			
	if not RoomPrp:
		return
		
	# ЕСЛИ ПОПАЛИ В ГЛУХОЙ ТУПИК: Просто перезапускаем всю сцену уровня с нуля!
	if fail_attempts >= 10:
		print("[ТУПИК] Ветка зажата геометрией. Перезапускаем всю сцену уровня...")
		#закомментировал эти строчки на время тестирования генерации
		#get_tree().reload_current_scene()
		#return

	# Если набрали нужное количество комнат — завершаем генерацию
	if RoomPrp.Room_num >= RoomPrp.Room_max:
		print("[ГЕНЕРАТОР] Генерация успешно завершена! Всего комнат: ", RoomPrp.Room_num)
		return

	old_dir = RoomPrp.dir
	
	# Выбор случайного направления
	match RoomPrp.dir:
		0, -1, 1:	
			match randi() % 3:
				0: pick_forward()
				1: pick_right()
				2: pick_left()
		-2: 
			pick_right()
		2: 
			pick_left()
			
	if room == null:
		return

	# Находим спавнер внутри только что созданной комнаты
	var next_spawner = room.get_node_or_null("map/RoomSpawner")
	if next_spawner:
		next_spawner.index = index + 1
		next_spawner.RoomPrp = RoomPrp

	# Вкладываем новую комнату «матрёшкой» внутрь текущего спавнера
	add_child(room)
	RoomPrp.Room_num += 1
	
	# Ждем два физических кадра, чтобы физический движок переместил комнату и обсчитал её коллизии
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	
	# Проверяем, не перезапустили ли мы уже сцену (защита от краша кода после yield)
	if not is_instance_valid(self):
		return
	
	# МГНОВЕННЫЙ ОПРОС ФИЗИКИ
	var has_collision = false
	var my_area = room.get_node_or_null("Area") # Ищем проверочную Area на корне созданной комнаты
	if not my_area:
		my_area = room.get_node_or_null("map/RoomSpawner/Area") # Страховка пути
		
	if my_area and my_area.has_method("get_overlapping_bodies"):
		var bodies = my_area.get_overlapping_bodies()
		for body in bodies:
			if body is StaticBody and not body.is_queued_for_deletion():
				var other_spawner = body.get_node_or_null("map/RoomSpawner")
				if not other_spawner and body.get_parent():
					other_spawner = body.get_parent().get_node_or_null("map/RoomSpawner")
				if not other_spawner and body.get_node_or_null("../map/RoomSpawner"):
					other_spawner = body.get_node_or_null("../map/RoomSpawner")
					
				# Если врезались в старого соседа по кругу (индекс меньше нашего родителя)
				if other_spawner:
					if other_spawner.index < index:
						print("[ФИЗИКА] Столкновение краями! Врезались в старого соседа №", other_spawner.index)
						has_collision = true
						break

	# ЕСЛИ МЕСТО СВОБОДНО (Коллизий с чужими старыми стенами нет)
	if not has_collision and is_instance_valid(room) and next_spawner:
		fail_attempts = 0
		
		# Удаляем проверочную зону позади нас
		var check_area = get_node_or_null("../../Area")
		if check_area:
			check_area.queue_free()
			
		next_spawner.spawn_room()
	else: 
		# ЕСЛИ МЕСТО ЗАНЯТО — Наращиваем счетчик неудачных попыток для этой точки
		fail_attempts += 1
		
		if is_instance_valid(room):
			remove_child(room)
			room.free() 
		room = null
		RoomPrp.Room_num -= 1
		
		RoomPrp.dir = old_dir
		
		# Слегка перемешиваем рандом при неудаче
		if randi() % 2 == 0:
			RoomPrp.dir = int(clamp(RoomPrp.dir + 1, -2, 2))
		else:
			RoomPrp.dir = int(clamp(RoomPrp.dir - 1, -2, 2))
		
		yield(get_tree(), "physics_frame")
		
		if is_instance_valid(self):
			spawn_room()


# Функции выбора комнат из массивов RoomProperties (без вылетов из-за "-1")
func pick_forward():
	if RoomPrp and RoomPrp.ForwardRooms.size() > 0:
		room = RoomPrp.ForwardRooms[randi() % RoomPrp.ForwardRooms.size()].instance()

func pick_left():
	if RoomPrp and RoomPrp.LeftRooms.size() > 0:
		room = RoomPrp.LeftRooms[randi() % RoomPrp.LeftRooms.size()].instance()
		RoomPrp.dir -= 1

func pick_right():
	if RoomPrp and RoomPrp.RightRooms.size() > 0:
		room = RoomPrp.RightRooms[randi() % RoomPrp.RightRooms.size()].instance()
		RoomPrp.dir += 1
