extends VBoxContainer

func _ready() -> void:
	$PlayButton.pressed.connect(_on_play_pressed)
	$DeckButton.pressed.connect(_on_deck_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/arena.tscn")

func _on_deck_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/deck_builder.tscn")
