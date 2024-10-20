extends Control  # or your relevant base class

const MAX_SLOTS = 7
var cards = []  # Holds the cards to be displayed in the hotbar

# Function to handle card setup
func _ready():
	_update_card_visuals()

# Update the visuals whenever the player's hand changes
func _update_card_visuals() -> void:
	# Ensure the hotbar displays the correct cards from the player's hand
	for i in range(MAX_SLOTS):
		var texture_rect = $HBoxContainer.get_child(i)
		if i < cards.size():
			var card = cards[i]
			if texture_rect and texture_rect is TextureRect:
				texture_rect.texture = card.card_portrait  # Set the card portrait for each slot
		else:
			# Clear the texture if no card is available for this slot
			texture_rect.texture = null
