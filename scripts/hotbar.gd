extends Control  # or your relevant base class
# Array to store references to the cards
var cards = []
# Array to store the loaded textures
var textures = []
var card_files = [
		load("res://assets/cards/MetaData/Draw.tres"),
		load("res://assets/cards/MetaData/Heal.tres"),
		load("res://assets/cards/MetaData/Weaken.tres"),
		load("res://assets/cards/MetaData/Rage.tres"),
]
# Function to handle card setup
func _ready():
	# Safely find the CardContainer/HBoxContainer
	var card_container = $HBoxContainer
	for card_data in card_files:
		cards.append(card_data)
	_update_card_visuals()


func _update_card_visuals() -> void:
	# Find the TextureRect children and set their textures based on card data
	for i in range(min(cards.size(), 4)):  # Assuming 4 TextureRects
		var texture_rect = $HBoxContainer.get_child(i)
		if texture_rect and texture_rect is TextureRect:
			texture_rect.texture = cards[i].card_portrait
