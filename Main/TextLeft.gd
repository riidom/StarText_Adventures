extends ColorRect


onready var Label = $Scroll/Margin/RichTextLabel


func _ready() -> void:
	Label.text = "Welcome onboard, captain!"
