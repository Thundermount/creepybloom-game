extends Resource

class_name Item

export(String) var name = ""
export(String) var description = ""
export(Texture) var sprite

enum type {
	POWERUP,
	WEAPON,
	ABILITY
}

export(type) var item_type = type.POWERUP
# Характеристики предмета которые прибавляются игроку
export(int) var HP = 0
export(int) var speed = 0
export(int) var attack_speed = 0
export(int) var damage = 0
export(int) var jump = 0
export(int) var projectile_speed = 0