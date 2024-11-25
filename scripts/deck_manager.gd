extends Node
class_name DeckManger
#to use getters and setters or just pass in funcitons ;/
var deck: Array[CardMetaData] = []
var hand: Array[CardMetaData] = []
var is_spell_active: bool = false
var countdown_time: float = 0
var current_spell: BaseSpell
var playerLocal: CharacterBody3D
var enemyLocal: CharacterBody3D
var first_robot: CharacterBody3D
var all_robots: Array[CharacterBody3D]= []


func setFirstRobot(char:CharacterBody3D):
	first_robot = char

var negated: bool = false
const DEFAULT_CARD = preload("res://assets/cards/portraits/defaultCard.png")
var cardInstance
func getAttack()-> int:
	return playerLocal.attack
func getPlayer()-> CharacterBody3D:
	return playerLocal
	
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

func set_first_robot(char:CharacterBody3D):
	first_robot = char
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


func startCountDown(currentSpell: BaseSpell, player:CharacterBody3D, enemy:CharacterBody3D, start_up_time: float) -> void:
	print("spell is :", currentSpell.spell_name, "spell count down is ",  currentSpell.start_up)
	print("starting countdown for spell: ", start_up_time)
	is_spell_active = true
	countdown_time = start_up_time
	var spell_scene = load("res://scenes/World_spell_card.tscn")
	var spell_instance = spell_scene.instantiate()
	#keep track of the curernt spell?
	current_spell = currentSpell
	current_spell.playerLocal = player
	current_spell.enemyLocal = enemy
	set_process(true)
	
func getIfSpellActive() -> bool:
	return is_spell_active


func negateCurrentCard()-> void:
	negated = true
	
func setCurrentCardInstance(instanceParam)-> void:
	cardInstance = instanceParam
	
func _process(delta: float) -> void:
	if !playerLocal:
		return
		
	if negated:
		current_spell.change_sprite(cardInstance, DEFAULT_CARD)
		current_spell = null
		cardInstance = null
		negated = false
		is_spell_active = false
		return
	
	# Only run countdown and spell resolution if a spell is active
	if is_spell_active and countdown_time > 0:
		countdown_time -= delta
		if abs(countdown_time - round(countdown_time)) < 0.006:
			print("Time remaining for spell to resolve: ", round(countdown_time))
			
		if countdown_time <= 0 and current_spell != null:
			print("Resolving spell: ", current_spell.spell_name)
			is_spell_active = false
			set_process(false)  # Disable process after spell completes

			# Check for player reference and free resources appropriately
			current_spell.resolve_spell(current_spell.playerLocal, current_spell.enemyLocal)
			await get_tree().create_timer(3).timeout
			if current_spell:
				current_spell.queue_free()
				current_spell = null
			if cardInstance:
				cardInstance.queue_free()
				cardInstance = null
			
			# Free resources after resolution or timeout
	else:
		is_spell_active = false  # Ensure it's false if no spell is active or countdown is over



# Add this new function to update robots dynamically
func addRobot(instance):
	all_robots.append(instance)
	
func getRobots():
	return all_robots
