extends CharacterBody3D

# Speed of the enemy
var gravity = -9.8
var speed = 2.0
var health = 100
var deck: Array[CardMetaData]
var hand: Array[CardMetaData]
@onready var nav_agent = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Player"
@onready var healthbar: ProgressBar = $SubViewport/Healthbar
@onready var bullet = load("res://scenes/bullet.tscn")
@onready var robot_body = $"PlayerModel/Robot_Skeleton/Skeleton3D/00Robot_Body_008"
var instance
var draw_timer: Timer
var action_timer: Timer
var attack= 20

func _ready() -> void:
	deck = AiDeckManager.preload_ai_deck(deck)
	print("robot deck is : ", deck)
	AiDeckManager.setDeck(deck)
	for i in range(5):
		hand.append(AiDeckManager.draw_card())
	# Set up timer for drawing cards periodically
	draw_timer = Timer.new()
	add_child(draw_timer)
	draw_timer.wait_time = 15  # Draw every 15 seconds
	draw_timer.connect("timeout", Callable(self, "_on_draw_timer_timeout"))
	draw_timer.start()

	# Set up timer for playing cards
	action_timer = Timer.new()
	add_child(action_timer)
	action_timer.wait_time = 5
	action_timer.connect("timeout", Callable(self, "_on_action_timer_timeout"))
	action_timer.start()
	

func _physics_process(delta):
	velocity = Vector3.ZERO
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * speed
	move_and_slide()
	
	# Rotate the enemy to face the player
	var look_at_position = player.global_transform.origin
	look_at(look_at_position, Vector3.UP)
	rotation.y += PI

func take_damage(amount:int) -> void:
	if(health< amount):
		amount = health
	health -= amount
	healthbar.value = health
	if(health ==0):
		queue_free()
	


func _on_area_3d_area_entered(area: Area3D) -> void:
	if(area.name == "BulletArea"):
		take_damage(2)

# Timer callback to draw a card
func _on_draw_timer_timeout() -> void:
	var drawn_card = AiDeckManager.draw_card()
	if drawn_card != null:
		hand.append(drawn_card)
		print("AI drew card: ", drawn_card.card_name)

# Timer callback to attempt to play a card
func _on_action_timer_timeout() -> void:
	if AiDeckManager.getIfSpellActive():
		print("spell is still active")
		return 
		
	if hand.size() == 0:
		print("AI has no cards to play.")
		return

	# Select a random card from the hand
	var random_index = randi() % hand.size()
	var selected_card = hand[random_index]
	
	match selected_card.card_type:
		"monster":
			play_monster_card(selected_card)
		"spell":
			play_spell_card(selected_card)
	
	# Remove the card from the hand after playing
	hand.remove_at(random_index)

# Function to play a monster card
func play_monster_card(card: CardMetaData) -> void:
	var monster_script = load(card.script_path)
	if monster_script != null:
		var monster_instance = monster_script.new()
		monster_instance.setupAttributes(card)
		var current_scene = get_tree().root.get_child(1)
		if current_scene:
			monster_instance.spawnMonster(self, current_scene, 5.0, Vector3(0.1, 0.1, 0.1))
		print("AI played monster card: ", card.card_name)

# Function to play a spell card
func play_spell_card(card: CardMetaData) -> void:
	if AiDeckManager.getIfSpellActive():
		print("AI cannot play spell, one is already active.")
		return
	
	var spell_script = load(card.script_path)
	if spell_script != null:
		var spell_instance = spell_script.new()
		var current_scene = get_tree().root.get_child(1)
		if current_scene:
			spell_instance.activate_spell(self, card, current_scene, 5.0, Vector3(1, 1, 1))
			spell_instance.resolve_spell(self)
			spell_instance.setupAttributes(card)
		print("AI played spell card: ", card.card_name)
