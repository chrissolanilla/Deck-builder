extends Control  # or your relevant base class


const MAX_SLOTS = 7
var cards = []  # Holds the cards to be displayed in the hotbar
#if we want to show a red x instead
# var default_texture = preload("res://assets/cards/portraits/defaultCard(1).png")
var score_label: Label

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
			
			
var score: int = 0

func increase_score(amount: int) -> void:
	score += amount
	print("score number: " , score)
	update_score_display()

func update_score_display() -> void:
	# Access the Label node inside Score slot
	score_label = $HBoxContainer.get_child(7).get_child(0)
	print("score: " , score_label)
	score_label.text = "Score: " + str(score)
	if score_label == null:
		print("Error: Label node in Score_slot not found!")
