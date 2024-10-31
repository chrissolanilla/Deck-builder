extends Control

@onready var node = $Control
var center : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center = Vector2(get_viewport_rect().size.x/2, get_viewport_rect().size.y/2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
