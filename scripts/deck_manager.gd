extends Node
class_name DeckManger
#to use getters and setters or just pass in funcitons ;/
var deck: Array[CardMetaData] = []
var hand: Array[CardMetaData] = []

func setDeck(newDeck: Array[CardMetaData]) -> void:
	deck = newDeck

func getDeck() ->Array[CardMetaData]:
	return self.deck

func setHand(newHand: Array[CardMetaData]) -> void:
	hand = newHand

func getHand() -> Array[CardMetaData]:
	return self.hand

func shuffle()-> void:
	deck.shuffle()

func addCardToHand(card: CardMetaData):
	if deck.has(card):
		hand.push_back(card)

# Draw a single card from the deck and return it
func draw_card() -> CardMetaData:
	if deck.size() > 0:
		var card_metadata = deck.pop_front()  # Draw the top card from the deck
		hand.append(card_metadata)  # Add it to the hand
		print("Drew card: ", card_metadata.card_name)
		return card_metadata  # Return the card that was drawn
	else:
		print("Deck is empty!")
		return null

func createUICard(metadata: CardMetaData):
	var card_scene = preload("res://scenes/ui_card_scene.tscn").instance()
	card_scene.setup_card(metadata)
	add_child(card_scene)
	return card_scene

func create3DCard(metadata: CardMetaData):
	var card_scene = preload("res://scenes/world_card_scene.tscn").instance()
	card_scene.setupCard(metadata)
	var arena = get_node("res://scenes/arena.tscn")
	arena.add_child(card_scene) #this will spawn a random floating card in the arena
	return card_scene


# Core load function (doesn't handle UI)
func loadCurrentDeck(deckArray: Array) -> Array:
	if not FileAccess.file_exists("user://savegame.data"):
		print("Save file does not exist.")
		return deckArray
	var file = FileAccess.open("user://savegame.data", FileAccess.READ)
	var savedDictionary = file.get_var()
	file.close()
	deckArray.clear()  # Clear the current deck
	# Load the cards from saved file paths in the deck
	if savedDictionary.has("deck"):
		var savedDeckArray = savedDictionary["deck"]
		for card_path in savedDeckArray:
			if card_path is String:
				var card_data = ResourceLoader.load(card_path)
				if card_data is CardMetaData:
					deckArray.append(card_data)
				else:
					print("Failed to load card: %s" % card_path)
			else:
				print("Invalid card path: %s" % card_path)

	print("Loaded deck: ",  deckArray)
	return deckArray
