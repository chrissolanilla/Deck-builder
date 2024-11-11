extends VBoxContainer
var deck: Array[CardMetaData] = []
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#load the savegame.data and see if we have atleast 5 cards in the file.
	deck = DeckManager.loadCurrentDeck(deck)
	#this condition fixes the null error when playing game
	if deck.size()< 5:
		$PlayButton.disabled = true
	$PlayButton.pressed.connect(_on_play_pressed)
	$DeckButton.pressed.connect(_on_deck_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lessLaggyLevel.tscn")

func _on_deck_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/deck_builder.tscn")
