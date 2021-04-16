extends Node2D

func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	position = mouse_pos + Vector2(0, -20)
	$xy.text = str(mouse_pos)
