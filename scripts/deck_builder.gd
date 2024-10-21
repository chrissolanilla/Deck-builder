extends Control

var available_cards: Array[CardMetaData] = []
var deck: Array[CardMetaData] = []
var gridContainer: Node
var mainDeckGridContainer: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	$ClearDeckButton.pressed.connect(_on_clear_deck_button_pressed)
	mainDeckGridContainer = $MainDeckList/ScrollContainer/MarginContainer/GridContainer
	gridContainer = $RightPanel/SearchGrid/ScrollContainer/MarginContainer/GridContainer
	# Load the cards as usual into our search results
	loadAvailableCards()
	#load our current deck in the json file
	deck = loadCurrentDeck(deck)
	print("Our loaded deck is ",  deck)
	# Connect the save button and bind the deck array
	$SaveButton.connect("pressed", Callable(self, "_on_save_button_pressed").bind(deck))
	$TitleScreenButton.pressed.connect(_on_title_screen_button_pressed)


#fibbonacci indentation would go crazy here
func loadAvailableCards():
	var dir = DirAccess.open("res://assets/cards/MetaData")
	if dir:
		print("Directory exists")
		dir.list_dir_begin()  # start reading the directory
		var file_name_real = dir.get_next()
		while file_name_real != "":
			print("File name: %s" % file_name_real)
			var file_name = file_name_real
			if file_name.ends_with(".remap"):
				file_name = file_name.substr(0, file_name.length() - 6)
			if not dir.current_is_dir():  # ensure it's not a subdirectory
				if file_name.ends_with(".tres"):
					print("Found .tres file: %s" % file_name)
					var card_data = ResourceLoader.load("res://assets/cards/MetaData/" + file_name)
					if card_data is CardMetaData:
						card_data.file_path = "res://assets/cards/MetaData/" + file_name
						available_cards.append(card_data)
						var ui_card = createUICard(card_data)
						gridContainer.add_child(ui_card)
						ui_card.connect("card_hovered", Callable(self, "_on_card_hovered"))
						ui_card.connect("card_hovered_exit", Callable(self, "_on_card_hovered_exit"))
						print("Adding child: %s" % card_data.card_name)
			file_name_real = dir.get_next()  # get the next file
		dir.list_dir_end()  # close directory access
	else:
		print("Directory could not be opened")

func createUICard(card_data: CardMetaData):
	var card_scene = preload("res://scenes/ui_card_scene.tscn")
	var instance = card_scene.instantiate()
	instance.setupCard(card_data)
	instance.connect("card_selected", Callable(self, "_on_card_selected").bind(card_data))
	instance.connect("card_dragged", Callable(self, "_on_card_dragged")) #do not use .bind(card_data) here
	return instance

func _on_card_selected(card_data: CardMetaData):
	deck.append(card_data)
	var deckCard = createUICard(card_data)
	mainDeckGridContainer.add_child(deckCard)
	#add singals for hover effects and to remove it
	deckCard.connect("gui_input", Callable(self, "_on_deck_card_gui_input").bind(deckCard, card_data))
	deckCard.connect("card_hovered", Callable(self, "_on_card_hovered"))
	deckCard.connect("card_hovered_exit", Callable(self, "_on_card_hovered_exit"))
	print("Added card: %s" % card_data.card_name)

#signal function to handle right-click to remove card from deck
func _on_deck_card_gui_input(event: InputEvent, card_instance: Control, card_data: CardMetaData):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		deck.erase(card_data)
		print("Removed card: %s" % card_data.card_name)
		card_instance.queue_free()

func _on_card_dragged(card_data: CardMetaData, mouse_pos: Vector2):
	# deck.erase(card_data)
	print("dragging card: %s and the mouse pos is %s" % [card_data.card_name, mouse_pos])

func _on_card_hovered(metadata : CardMetaData):
	$LeftPanel/CardTitle.text = metadata.card_name
	$LeftPanel/CardDescription.text = metadata.description
	$LeftPanel/CardEffect.text = metadata.effect
	#add a card scene or maybe just an image sprite to the $CardPreview
	$LeftPanel/CardPreview/TextureRect.texture = metadata.card_portrait


#when save button pressed, write it to a file(data file instead of json since knows type of .tres)
func _on_save_button_pressed(deckArray: Array) -> void:
	print("button pressed")
	var saveDictionary = {}
	var savedDeckArray = []
	#save each card's file path instead of the object itself since it cant handle encoding
	for card in deckArray:
		if card.file_path != null and card.file_path != "":
			savedDeckArray.append(card.file_path)  # make sure its a string
		else:
			print("Warning: Card %s does not have a valid file_path." % card.card_name)

	saveDictionary["deck"] = savedDeckArray
	#save the dictionary to a file
	var file = FileAccess.open("user://savegame.data", FileAccess.WRITE)
	#WARNING!!!! MUST READ IF EDITING THIS CODE!!!!,
	#if we add more variables to the savegame.data, the order of varialbes WILL MATTER
	#thankfully we only have one variable in this file which is a dictionary so inside the dictonary, order will not matter
	#basically a json file inside this .data file
	file.store_var(saveDictionary)
	file.close()
	print("Successfully saved deck: ", savedDeckArray)

func loadCurrentDeck(deckArray: Array) -> Array:
	#when we first play our game, savegame.data will not exist
	if not FileAccess.file_exists("user://savegame.data"):
		print("Save file does not exist.")
		return deckArray

	var file = FileAccess.open("user://savegame.data", FileAccess.READ)
	var savedDictionary = file.get_var()
	file.close()
	deckArray.clear()  # prob safe to clear the current deck incase its populated for some reason
	# load the cards from the file paths saved in the deck
	if savedDictionary.has("deck"):
		var savedDeckArray = savedDictionary["deck"]
		for card_path in savedDeckArray:
			if card_path is String:
				var card_data = ResourceLoader.load(card_path)
				if card_data is CardMetaData:
					deckArray.append(card_data)
					# add the card to the UI (mainDeckGridContainer)
					var deckCard = createUICard(card_data)
					mainDeckGridContainer.add_child(deckCard)
					# connect any necessary signals
					deckCard.connect("gui_input", Callable(self, "_on_deck_card_gui_input").bind(deckCard, card_data))
					deckCard.connect("card_hovered", Callable(self, "_on_card_hovered"))
					deckCard.connect("card_hovered_exit", Callable(self, "_on_card_hovered_exit"))
				else:
					print("Failed to load card: %s" % card_path)
			else:
				print("Invalid card path: %s" % card_path)

	print("Loaded deck: ",  deckArray)
	return deckArray

func _on_clear_deck_button_pressed() -> void:
	deck.clear()
	for card in mainDeckGridContainer.get_children():
		card.queue_free()
	print("cleared deck: ", deck)

func _on_title_screen_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
