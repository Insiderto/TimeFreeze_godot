extends Area2D

@export_file("*.tscn") var next_level: String = "res://scenes/Round_2.tscn"

func _on_body_entered(body: Node2D):
	get_tree().change_scene_to_file(next_level)
