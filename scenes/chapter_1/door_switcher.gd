extends Area2D


func _on_body_entered(body):
	$door_enabled.visible = true
	$door_disabled.visible = false
	$"../GoalDoor/DoorLocked".visible = false
	$"../GoalDoor/DoorOpen".visible = true
