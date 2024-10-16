extends Control  # or your relevant base class

# Array to store references to the cards
var cards = []
# Array to store the loaded textures
var textures = []

# Function to handle card setup
func _ready():
	# Load all textures from the portraits folder
	_load_textures()

	# Safely find the CardContainer/HBoxContainer
	var card_container = $HBoxContainer
	
	# Check if card_container is valid
	if card_container == null:
		print("Card container not found!")
		return
	
	# Iterate over all TextureRect children (cards) in the container
	for card in card_container.get_children():
		if card is TextureRect:
			cards.append(card)  # Store each card in the array
			card.connect("gui_input", _on_card_input)
	
	# Randomly assign textures to the cards
	_assign_random_textures()

# Function to load textures from the portraits folder
func _load_textures() -> void:
	var texture_paths = [
		"res://assets/cards/portraits/Creamius_Pantaloonius.png",
		"res://assets/cards/portraits/desert_world.png",
		"res://assets/cards/portraits/immortal_king.png",
		"res://assets/cards/portraits/team_cream.png"
	]
	
	for path in texture_paths:
		var texture = load(path)
		if texture:
			textures.append(texture)
		else:
			print("Failed to load texture: ", path)

# Function to randomly assign textures to the cards
func _assign_random_textures() -> void:
	for card in cards:
		var random_texture = textures[randi() % textures.size()]
		card.texture = random_texture  # Assign a random texture to the TextureRect

# Function to handle input when a card is clicked
func _on_card_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Card selected by mouse")

# Function to handle keyboard input
func _input(event: InputEvent) -> void:
	# Check if the event is a key press and a number key is pressed
	if event is InputEventKey and event.pressed:
		# Handle number keys (1-7)
		match event.keycode:
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7:
				var index = event.keycode - KEY_1  # Get index from 0-6
				select_card_by_index(index)

# Function to select a card by its index
func select_card_by_index(index: int) -> void:
	if index >= 0 and index < cards.size():
		var selected_card = cards[index]
		print("Card selected by key press: ", selected_card.name)  # or handle selection logic
	else:
		print("Invalid card index")
