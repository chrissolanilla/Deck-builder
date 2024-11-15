extends Control  # or your relevant base class


const MAX_SLOTS = 7
var cards = []  # Holds the cards to be displayed in the hotbar
#if we want to show a red x instead
# var default_texture = preload("res://assets/cards/portraits/defaultCard(1).png")


# Function to handle card setup
func _ready():
	_update_card_visuals()

# Update the visuals whenever the player's hand changes
func _update_card_visuals() -> void:
	for card in cards:
		print("cards in hand is: ", card.card_name)
	# Ensure the hotbar displays the correct cards from the player's hand
	for i in range(MAX_SLOTS):
		var texture_rect = $HBoxContainer.get_child(i)
		var number_label = texture_rect.get_child(0)
		if i < cards.size():
			var card = cards[i]
			if texture_rect and texture_rect is TextureRect:
				texture_rect.texture = card.card_portrait  # Set the card portrait for each slot
				number_label.text = str(i+1)
		else:
			# Clear the texture if no card is available for this slot
			# texture_rect.texture = null
			# texture_rect.texture = default_texture
			texture_rect.texture = null
			number_label.text = ""
			
			
