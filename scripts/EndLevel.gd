extends Node

func EndLevel():
	var next_level = LevelData.level + 1
	get_tree().change_scene("res://levels/Room"+ String(next_level) +".tscn")



func _on_EndLevelTrigger_body_entered(body):
	if body.name == "Player":
		body.disable_movement = true
		
		yield(get_tree().create_timer(4.0), "timeout")
		EndLevel()
