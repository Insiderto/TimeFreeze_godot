extends Node2D

func _ready():
	Engine.time_scale = 1
	
func _input(event):
	if event.is_action_pressed("freeze_time"):
		Engine.time_scale = 0.05
	if event.is_action_released("freeze_time"):
		Engine.time_scale = 1
	if event.is_action_pressed("restart_game"):
		get_tree().reload_current_scene()
