extends Resource

class_name HealthSystem

export(int) var HP = 3
export(int) var MAX_HP = 9
export(int) var damage = 1
export(float) var bullet_lifetime = 5.0
export(int) var push_force = 1

signal die
signal HP_changed

func change_HP(var amount):
	if HP + amount > MAX_HP:
		HP = MAX_HP
	else:
		HP += amount
	HP_changed()
	
func set_HP(var amount):
	if amount > MAX_HP:
		HP = MAX_HP
	else:
		HP = amount
	HP_changed()
		
func HP_changed():
	emit_signal("HP_changed")
	if HP > 0: return
	emit_signal("die")
	

