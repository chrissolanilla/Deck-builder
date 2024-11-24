extends CharacterBody3D
# Speed of the enemy
var gravity = -9.8
var speed = 2.0
var health = 100
var deck: Array[CardMetaData]
var hand: Array[CardMetaData]
var jump_stage = 0
var strafe_stage = 0
var to_player 
var perpendicular_dir 
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var skeleton_3d: Skeleton3D = $PlayerModel/Robot_Skeleton/Skeleton3D
@onready var animation_player: AnimationPlayer = $PlayerModel/AnimationPlayer
@onready var nav_agent = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Player"
@onready var healthbar: ProgressBar = $SubViewport/Healthbar
@onready var bullet = load("res://scenes/bullet.tscn")
@onready var robot_body = $"PlayerModel/Robot_Skeleton/Skeleton3D/00Robot_Body_008"
@onready var animation_tree: AnimationTree = $PlayerModel/AnimationTree
var instance
var draw_timer: Timer
var action_timer: Timer
var attack_timer: Timer
var attack= 20
enum State { APPROACH, MELEE, STRAFE, LOW_HEALTH, TARGET_LOW_HEALTH, JUMP }
var state = State.APPROACH
#walking animation name is xxx_001-noexp
var attack_range = 2.0
var disoriented: bool = false

func _ready() -> void:
	to_player = player.global_transform.origin - global_transform.origin
	perpendicular_dir = to_player.cross(Vector3.UP).normalized()  # Perpendicular to player direction
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

	#timer for attack
	attack_timer = Timer.new()
	add_child(attack_timer)
	attack_timer.wait_time = 1
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
	# Set up timer for playing cards
	action_timer = Timer.new()
	add_child(action_timer)
	action_timer.wait_time = 5
	action_timer.connect("timeout", Callable(self, "_on_action_timer_timeout"))
	action_timer.start()


func _physics_process(delta):
	var _position = skeleton_3d.global_position
	print(_position)
	var _offset = Vector2(_position.x, _position.y)
	print(_offset)
	sprite_3d.global_position = _position+Vector3(0,3,0)
	
	to_player = player.global_transform.origin - global_transform.origin
	perpendicular_dir = to_player.cross(Vector3.UP).normalized()  # Perpendicular to player direction
	#switch state to attack if in range
	#should i be using an enum for state so it can have multiple states at a time?
	#not sure if having multiple states at a time is good for a state machine or finite one. 
	if !is_on_floor():
		velocity += get_gravity() * delta
	if health < 50 and state != State.LOW_HEALTH:
		state = State.LOW_HEALTH
	#if i am in melee range for an extended period of time, it wont keep repeating his attack animation 
	#but it wont deal me damage until i ledave the attack range
	elif _target_in_range():
		state = State.MELEE
	elif health>50 and !disoriented:
		state = State.APPROACH
	
	match state:
		State.APPROACH:
			approach_player()
			setAnimationParamsToZero()
			animation_tree.set("parameters/Run/blend_amount", 1)
		State.MELEE:
			melee_attack()
			setAnimationParamsToZero()
			animation_tree.set("parameters/Attack/blend_amount", 1)
		State.STRAFE:
			strafe()
		State.LOW_HEALTH:
			low_health_behavior()
		State.TARGET_LOW_HEALTH:
			target_low_health_behavior()
		State.JUMP:
			jump_behavior()
			
func setAnimationParamsToZero():
	animation_tree.set("parameters/Attack/blend_amount", 0)
	animation_tree.set("parameters/Run/blend_amount", 0)
	animation_tree.set("parameters/J/blend_amount", 0)
	animation_tree.set("parameters/Ju/blend_amount", 0)
	animation_tree.set("parameters/Jum/blend_amount", 0)
	animation_tree.set("parameters/Jump/blend_amount", 0)
	animation_tree.set("parameters/Jumps/blend_amount", 0)
	animation_tree.set("parameters/Strafe/blend_amount", 0)
	animation_tree.set("parameters/Strafer/blend_amount", 0)

func take_damage(amount:int) -> void:
	if(health< amount):
		amount = health
	health -= amount
	healthbar.value = health
	
	  # Notify hotbar to increase the score
	if amount > 0:
		var hotbar = get_parent().get_node("CardContainer")  # Adjust path to match your scene structure
		if hotbar != null:
			hotbar.increase_score(amount)
	if(health ==0):
		queue_free()
		get_tree().change_scene_to_file("res://scenes/EndScreen.tscn")
	
func _on_area_3d_area_entered(area: Area3D) -> void:
	if(area.name == "BulletArea"):
		take_damage(2)

# Timer callback to draw a card
func _on_draw_timer_timeout() -> void:
	var drawn_card = AiDeckManager.draw_card()
	if drawn_card != null:
		hand.append(drawn_card)
		print("AI drew card: ", drawn_card.card_name)

func _on_attack_timer_timeout()  -> void:
	player.take_damage(attack)
	attack_timer.stop()
	
# Timer callback to attempt to play a card
#we should check our state though and prioritize to play a card in our hand like heal if low health. 
func _on_action_timer_timeout() -> void:
	if AiDeckManager.getIfSpellActive():
		print("spell is still active")
		return 
		
	if hand.size() == 0:
		print("AI has no cards to play.")
		return
	# Select cards based on current state
	var selected_card
	match state:
		State.LOW_HEALTH:
			selected_card = find_card_by_type("heal")
		State.TARGET_LOW_HEALTH:
			selected_card = find_card_by_type("attack")
		_:
			selected_card = hand[randi() % hand.size()]  # Default to random card

	if selected_card:
		match selected_card.card_type:
			"monster":
				play_monster_card(selected_card)
			"spell":
				play_spell_card(selected_card)
		hand.erase(selected_card)  # Remove card from hand after playing
	
	# Remove the card from the hand after playing
	#hand.remove_at(random_index)

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
			spell_instance.activate_spell(self, player, card, current_scene, 5.0, Vector3(1, 1, 1))
			#spell_instance.resolve_spell(self, player)
			spell_instance.setupAttributes(card)
		print("AI played spell card: ", card.card_name)
		
func _target_in_range():
	return global_position.distance_to(player.global_position) < attack_range

func approach_player():
	#play the xxx_001-noexp animation
	animation_player.play("xxx_001-noexp")
	velocity = Vector3.ZERO
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * speed
	move_and_slide()
	look_at(player.global_transform.origin, Vector3.UP)
	rotation.y += PI  # Face the player

func melee_attack():
	if !attack_timer.is_stopped():
		return
	attack_timer.start()
	animation_player.play("zDSDASD-noexp")
	#player.take_damage(attack)  # Apply damage to the player
	
	# Implement any knockback or animation handling here

func strafe():
	# Play strafing animations and adjust velocity for actual movement

	if strafe_stage == 0:
		print("STRAFE STAGE IS 0")
		
		animation_player.play("strafe_left")
		velocity = -perpendicular_dir * speed  # Move left relative to player

	elif strafe_stage == 1:
		print("STRAFE STAGE IS 1")
		animation_player.play("strafe_right")
		velocity = perpendicular_dir * speed  # Move right relative to player
		

	# Apply the movement to the character's position
	move_and_slide()

func low_health_behavior():
	# Attempt to heal if a healing card is available
	var healing_card = find_card_by_type("heal")
	if healing_card != null:
		play_spell_card(healing_card)
		hand.erase(healing_card)
		return  # Exit after playing a healing card
	 # Randomly decide to jump or strafe
	if randi() % 3 == 0:  # Roughly 1 in 3 chance to jump
		state = State.JUMP
	else:
		strafe()  # Default to strafing if not jumping
	# If no healing card is available, initiate strafing behavior
	strafe()  # Call the strafe function for dodging

func target_low_health_behavior():
	# Implement aggressive targeting behavior here
	pass

func jump_behavior():
	if jump_stage == 0 and is_on_floor():
		animation_player.play("jump_1_up")
		#animatin_finished is a signal? do i have to connect it or something and have a _on_finsihed funciton?
		await animation_player.animation_finished
		jump_stage = 1
	elif jump_stage == 1:
		animation_player.play("jump_2_upwards")
		await animation_player.animation_finished
		jump_stage = 2
	elif jump_stage == 2:
		animation_player.play("jump_3_midair")
		await animation_player.animation_finished
		jump_stage = 3
	elif jump_stage == 3:
		animation_player.play("jump_4_falling")
		await animation_player.animation_finished
		jump_stage = 4
	elif jump_stage == 4:
		animation_player.play("jump_5_hardlanding")
		await animation_player.animation_finished
		jump_stage = 0  # Reset jump cycle
		
func find_card_by_type(card_type: String) -> CardMetaData:
	for card in hand:
		if card != null:
			if card.card_name == card_type:
				return card
	return null  # Return null if no matching card is found


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("OUR ANIMATINO HAS FINISHED")
	match jump_stage:
		0:
			animation_player.play("jump_2_upwards")
			jump_stage = 1
		1:
			animation_player.play("jump_3_midair")
			jump_stage = 2
		2:
			animation_player.play("jump_4_falling")
			jump_stage = 3
		3:
			animation_player.play("jump_5_hardlanding")
			jump_stage = 4
		4:
			jump_stage = 0  # Reset jump cycle after landing

	# Decide strafe direction based on perpendicular relation to player
	if anim_name == "strafe_left" or anim_name == "strafe_right":
		# Check if the player is still perpendicular after strafing
		to_player = player.global_transform.origin - global_transform.origin
		perpendicular_dir = to_player.cross(Vector3.UP).normalized()

		# If robot's position is right of the player, strafe left; if left, strafe right
		if to_player.dot(perpendicular_dir) > 0:
			strafe_stage = 0  # Set to strafe left
			animation_player.play("strafe_left")
		else:
			strafe_stage = 1  # Set to strafe right
			animation_player.play("strafe_right")

func disorient(duration: float) -> void:
	disoriented = true
	print("Disorienting the robot for ", duration, " seconds")
	state = null  # Disable the state machine temporarily
	velocity = Vector3.ZERO
	move_and_slide()  # To stop any residual velocity
	# Remove the target position to stop pathfinding
	nav_agent.target_position = global_transform.origin  # Setting target to current position effectively "stops" it

	# Use a Timer to re-enable movement after the duration
	var disorient_timer = Timer.new()
	add_child(disorient_timer)
	disorient_timer.wait_time = duration
	disorient_timer.one_shot = true
	disorient_timer.connect("timeout", Callable(self, "_on_disorient_timeout"))
	disorient_timer.start()

func _on_disorient_timeout() -> void:
	disoriented = false
	print("Robot disorient effect ended")
	state = State.APPROACH  # Set the robot back to a state to continue normal behavior
