extends Node
class_name AI_DeckManger
#to use getters and setters or just pass in funcitons ;/
var deck: Array[CardMetaData] = []
var hand: Array[CardMetaData] = []
var is_spell_active: bool = false
var countdown_time: float = 0
var current_spell: BaseSpell
var playerLocal: CharacterBody3D
var negated: bool = false
var cardInstance
const DEFAULT_CARD = preload("res://assets/cards/portraits/defaultCard.png")

func preload_ai_deck(deckParam:Array[CardMetaData]) -> Array[CardMetaData]:
	# Manually populate the AI's deck with specific cards
	var cards = [
		#"res://assets/cards/MetaData/Cursed_scarab.tres",
		"res://assets/cards/MetaData/Heal.tres",
		"res://assets/cards/MetaData/Rage.tres",
	]
	#add each card in his deck list 3 times. 
	for card in cards:
		card = ResourceLoader.load(card)
		print("appending ", card)
		deckParam.append(card)
		deckParam.append(card)
		deckParam.append(card)
		
	return deckParam
		

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

func create3DCard(metadata: CardMetaData):
	var card_scene = preload("res://scenes/world_card_scene.tscn").instance()
	card_scene.setupCard(metadata)
	var arena = get_node("res://scenes/arena.tscn")
	arena.add_child(card_scene) #this will spawn a random floating card in the arena
	return card_scene

func startCountDown(currentSpell: BaseSpell, player:CharacterBody3D , start_up_time: float) -> void:
	if is_spell_active:
		print("a spell is alreadyactive")
		return
	print("starting countdown for spell: ", currentSpell)
	is_spell_active = true
	countdown_time = start_up_time
	print("COUNT DOWN TIME IS ", countdown_time, "AND BOOLEAN IS ", is_spell_active)
	#keep track of the curernt spell?
	current_spell = currentSpell
	#what is this for?
	current_spell.playerLocal = player
	set_process(true)



func getIfSpellActive() -> bool:
	return is_spell_active


func negateCurrentCard()-> void:
	negated = true
	print("set negate to true")
	
func setCurrentCardInstance(instanceParam)-> void:
	cardInstance = instanceParam
	
func _process(delta: float) -> void:
	#print("in the process function")
	#print("current spell is : ", current_spell)
	if current_spell == null:
		#print("current spell is null right now")
		return
	
	if negated:
		print("WE ARE NEGATED RIGHT NOW")
		current_spell.change_sprite(cardInstance, DEFAULT_CARD)
		current_spell= null
		cardInstance = null
		negated = false
		is_spell_active= false
		
		
		#somehow make negated false again after we negate our card but dont resolve the spell
	if is_spell_active and countdown_time > 0:
		countdown_time -= delta
		if abs(countdown_time - round(countdown_time)) < 0.006:
			print("Time remaining for spell to resolve: ", round(countdown_time))


		if countdown_time <= 0:
			print("Resolving spell: ", current_spell.spell_name)
			is_spell_active = false
			set_process(false)  # Disable process
			current_spell.resolve_spell(current_spell.playerLocal)
			current_spell.queue_free()  # Free the spell instance after it resolves
			cardInstance.queue_free()
			
