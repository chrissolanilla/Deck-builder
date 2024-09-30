extends Control

var available_cards: Array[CardMetaData] = []
var deck: Array[CardMetaData] = []
var gridContainer
# Path to save the deck
var deck_save_path = "user://deck_data.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var gridContainer = $ScrollContainer/MarginContainer/GridContainer
	# Load the cards as usual
	loadAvailableCards()

func loadAvailableCards():
	var dir = DirAccess.open("res://assets/cards/MetaData")
	if dir:
		print("Directory exists")
		dir.list_dir_begin()  # start reading the directory
		var file_name = dir.get_next()
		while file_name != "":
			print("File name: %s" % file_name)
			if not dir.current_is_dir():  # ensure it's not a subdirectory
				if file_name.ends_with(".tres"):
					print("Found .tres file: %s" % file_name)
					var card_data = ResourceLoader.load("res://assets/cards/MetaData/" + file_name)
					if card_data is CardMetaData:
						available_cards.append(card_data)
						var ui_card = createUICard(card_data)
						$ScrollContainer/MarginContainer/GridContainer.add_child(ui_card)
						ui_card.connect("card_hovered", Callable(self, "_on_card_hovered"))
						ui_card.connect("card_hovered_exit", Callable(self, "_on_card_hovered_exit"))
						print("Adding child: %s" % card_data.card_name)
			file_name = dir.get_next()  # get the next file
		dir.list_dir_end()  # close directory access
	else:
		print("Directory could not be opened")

func createUICard(card_data: CardMetaData):
	var card_scene = preload("res://scenes/ui_card_scene.tscn")
	var instance = card_scene.instantiate()
	instance.setupCard(card_data)
	instance.connect("card_selected", Callable(self, "_on_card_selected").bind(card_data))
	instance.connect("card_dragged", Callable(self, "_on_card_dragged").bind(card_data))
	return instance

func _on_card_selected(card_data: CardMetaData):
	deck.append(card_data)
	print("Added card: %s" % card_data.card_name)

func save_deck():
	print("Deck saved (not really implemented yet): %s" % deck)
	
func _on_card_hovered(metadata : CardMetaData):
	$BottomPanel/CardTitle.text = metadata.card_name
	$BottomPanel/CardDescription.text = metadata.description
	$BottomPanel/CardEffect.text = metadata.effect
