extends Container

onready var StarMap = $Starmap


func _ready() -> void:
	rect_size = Vector2(StarMap.get_size(), StarMap.get_size())
