extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if ($DoorOpen.visible):
		get_tree().change_scene_to_file("res://scenes/chapter_1/Round_1.tscn")
