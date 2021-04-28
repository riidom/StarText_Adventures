extends MarginContainer

onready var Label = $Label


var time := 0.0
var duration := 2.0


func _process(delta: float) -> void:
	if time < duration:
		time += delta
	Label.set_self_modulate(lerp(
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		ease(time / duration, 3)
	))

	
func display_message(text: String) -> void:
	Label.text = text
	time = 0
