extends Weapon

export(Array) onready var bullet_scenes

var rng = RandomNumberGenerator.new()

func instance_bullet():
	var i = rng.randi_range(0, bullet_scenes.size()-1)
	return bullet_scenes[i].instance()
