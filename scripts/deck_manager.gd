extends Node
class_name DeckManger

var deck: Array[CardMetaData] = []
var hand: Array[Node] = []

func addCardToHand(card: CardMetaData):
	deck.append(card)
	
func drawCard():
	if deck.size() > 0:
		var card_metadata = deck.pop_front()
		var ui_card = createUICard(card_metadata)
		var world_card = create3DCard(card_metadata)
		hand.append(ui_card)
		hand.append(world_card)
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

func saveDeck(param_deck: Array):
	self.deck = param_deck
