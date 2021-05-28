extends MarginContainer

onready var Label = $Label


var time := 0.0
var duration := 3.0


func _process(delta: float) -> void:
	if time < duration:
		time += delta
	Label.set_self_modulate(lerp(
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		ease(time / duration, 3)
	))

	
func display_message(text: String, slow: bool = false) -> void:
	Label.text = text
	time = 0
	duration = 3.0 if !slow else 6.0


func _on_nav_started() -> void:
	display_message(T.get("A_Nav_Instructions"), true)

