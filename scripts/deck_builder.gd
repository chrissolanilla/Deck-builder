extends Control

var available_cards: Array[CardMetaData] = []
var deck: Array[CardMetaData] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadAvailableCards()

func loadAvailableCards():
	var dir = DirAccess.open("res://assets/cards/MetaData")
	if dir:
		print("Directory exists")
		dir.list_dir_begin()  # Start reading the directory
		var file_name = dir.get_next()
		while file_name != "":
			print("File name: %s" % file_name)
			if not dir.current_is_dir():  # Ensure it's not a subdirectory
				if file_name.ends_with(".tres"):
					print("Found .tres file: %s" % file_name)
					var card_data = ResourceLoader.load("res://assets/cards/MetaData/" + file_name)
					if card_data is CardMetaData:
						available_cards.append(card_data)
						var ui_card = createUICard(card_data)
						$GridContainer.add_child(ui_card)
						print("Adding child: %s" % card_data.card_name)
			file_name = dir.get_next()  # Get the next file
		dir.list_dir_end()  # Close directory access
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
