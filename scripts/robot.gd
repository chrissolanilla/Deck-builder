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
var canChangeState:bool= true
var recursionLevel=1
@onready var shoot: AudioStreamPlayer3D = $Shoot
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var skeleton_3d: Skeleton3D = $PlayerModel/Robot_Skeleton/Skeleton3D
@onready var animation_player: AnimationPlayer = $PlayerModel/AnimationPlayer
@onready var nav_agent = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Player"
#var player = DeckManager.getPlayer()
@onready var healthbar: ProgressBar = $SubViewport/Healthbar
@onready var bullet = load("res://scenes/bullet.tscn")
@onready var step: AudioStreamPlayer3D = $Step
@onready var stepTimer: Timer = $stepTimer
@onready var robot_body = $"PlayerModel/Robot_Skeleton/Skeleton3D/00Robot_Body_008"
@onready var animation_tree: AnimationTree = $PlayerModel/AnimationTree
var recursionCard = ResourceLoader.load("res://assets/cards/MetaData/recursion_monster.tres")

var instance
var draw_timer: Timer
var action_timer: Timer
var attack_timer: Timer
var attack= 20
enum State { APPROACH, MELEE, STRAFE, LOW_HEALTH, TARGET_LOW_HEALTH, JUMP, RETREAT }
var state = State.APPROACH
#walking animation name is xxx_001-noexp
var attack_range = 2.0
var disoriented: bool = false
var recursionPlayCount: float = 0

func _ready() -> void:
	if self.name == "Robot":
		print("MY NAME IS ROBOT")
		DeckManager.setFirstRobot(self)
	print("recursion count is", recursionLevel)
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
	action_timer.wait_time = 3
	action_timer.connect("timeout", Callable(self, "_on_action_timer_timeout"))
	action_timer.start()


func _physics_process(delta):
	print("our state rn is ", state)
	healthbar.value = health
	if recursionLevel <= 0.1:
		queue_free()
	to_player = player.global_transform.origin - global_transform.origin
	perpendicular_dir = to_player.cross(Vector3.UP).normalized()  # Perpendicular to player direction
	look_at(player.global_transform.origin, Vector3.UP)
	rotation.y += PI  # Face the player
	#switch state to attack if in range
	#should i be using an enum for state so it can have multiple states at a time?
	#not sure if having multiple states at a time is good for a state machine or finite one.
	if !is_on_floor():
		velocity += get_gravity() * delta
	if health < 50 and state != State.LOW_HEALTH and canChangeState:
		#low_health_behavior()
		pass
	#if i am in melee range for an extended period of time, it wont keep repeating his attack animation
	#but it wont deal me damage until i ledave the attack range
	elif _target_in_range() and canChangeState:
		state = State.MELEE
	# elif health>50 and !disoriented:
	# 	state = State.APPROACH

	if canChangeState:
		match state:
			State.APPROACH:
				approach_player()
				setAnimationParamsToZero()
				animation_tree.set("parameters/Run/blend_amount", 1)
			State.MELEE:
				stepTimer.stop()
				melee_attack()
				setAnimationParamsToZero()
				animation_tree.set("parameters/Attack/blend_amount", 1)
			State.STRAFE:
				strafe()
			State.TARGET_LOW_HEALTH:
				target_low_health_behavior()
			State.JUMP:
				stepTimer.stop()
				jump_behavior()
			State.RETREAT:
				retreat_from_player()
	move_and_slide()

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

func _on_area_3d_area_entered(area: Area3D) -> void:
	if(area.name == "BulletArea"):
		if recursionLevel <0.8:
			print("hit recursive robot")
			take_damage(10)
		else:
			take_damage(2)
	
		DeckManager.enemyLocal = self

# Timer callback to draw a card
func _on_draw_timer_timeout() -> void:
	var drawn_card = AiDeckManager.draw_card()
	if drawn_card != null:
		hand.append(drawn_card)
		print("AI drew card: ", drawn_card.card_name)

func _on_attack_timer_timeout()  -> void:
	player.take_damage(attack)
	attack_timer.stop()
	canChangeState = true

	shoot.play()
	stepTimer.start()
	state = State.APPROACH

# Timer callback to attempt to play a card
#we should check our state though and prioritize to play a card in our hand like heal if low health.
func randomState() -> void:
	stepTimer.start()
	# Select cards based on current state
	if health >=50:
		var next_state = randi() %4
		match next_state:
			0:
				state = State.APPROACH
			1:
				state = State.STRAFE
			2:
				state = State.JUMP
			3:
				state = State.RETREAT

		play_cards()

func play_cards():
	var selected_card
	if hand.size() >0:

		match state:
			State.LOW_HEALTH:
				selected_card = find_card_by_type("heal")
			State.TARGET_LOW_HEALTH:
				selected_card = find_card_by_type("attack")
			_:
				selected_card = hand[randi() % hand.size()]  # Default to random card
	if hand.size() > 0 and !AiDeckManager.getIfSpellActive() and selected_card:
		match selected_card.card_type:
			"monster":
				play_monster_card(selected_card)
			"spell":
				play_spell_card(selected_card)
		hand.erase(selected_card)  # Remove card from hand after playing

func _on_action_timer_timeout() -> void:
	randomState()

# Function to play a monster card
func play_monster_card(card: CardMetaData) -> void:
	if card.card_name == "RecursionMonster":
		var monster_script = load(card.script_path)
		if monster_script != null:
			var monster_instance = monster_script.new()
			#monster_instance.setupAttributes(card)
			var current_scene = get_tree().root.get_child(3).get_child(1)
			if current_scene:
				recursionLevel-=0.2
				monster_instance.spawnMonster(self, current_scene, 5.0, Vector3(0.1, 0.1, 0.1), recursionLevel-recursionPlayCount)
				DeckManager.addRobot(monster_instance)
				recursionPlayCount+=0.1
				monster_instance.attack = 20*recursionLevel
				monster_instance.health = 100*recursionLevel
				monster_instance.recursionLevel = recursionLevel
				print("passing in recursion level as : " , recursionLevel)
				monster_instance.nerfSelf(recursionLevel)
			print("AI played monster card: ", card.card_name)
	else: 
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
		#spawn robot in the navigation region
	var spell_script = load(card.script_path)
	if spell_script != null:
		var spell_instance = spell_script.new()
		var current_scene = get_tree().root.get_child(1)
		if current_scene:
			spell_instance.activate_spell(self, player, card, current_scene, 5.0, Vector3(1, 1, 1))
			#spell_instance.resolve_spell(self, player)
			spell_instance.setupAttributes(card)
		print("AI played spell card: ", card.card_name)
		
		
#somehow make the spell spawn the robot in the get_world_tree but in the map node or something. 
#func play_spell_card(card: CardMetaData) -> void:
	#if AiDeckManager.getIfSpellActive():
		#print("AI cannot play spell, one is already active.")
		#return
#
	#var spell_script = load(card.script_path)
	#if spell_script != null:
		## Instance the spell
		#var spell_instance = spell_script.new()
		#spell_instance.setupAttributes(card)
#
		## Set up the current scene and activate the spell
		#var current_scene = get_tree().root.get_child(1)  # Adjust this if necessary
		#if current_scene:
			#spell_instance.activate_spell(self, player, card, current_scene, 5.0, Vector3(1, 1, 1))
#
			## Resolve the spell effect if it's RecursionSpell
			#if spell_instance is RecursionSpell:
				#spell_instance.resolve_spell(self, player)
#
		#print("AI played spell card: ", card.card_name)

func _target_in_range():
	return global_position.distance_to(player.global_position) < attack_range

func approach_player():
	velocity = Vector3.ZERO
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * speed
	move_and_slide()
	look_at(player.global_transform.origin, Vector3.UP)
	rotation.y += PI  # Face the player

func retreat_from_player():
	velocity = Vector3.ZERO

	# Calculate the direction vector pointing away from the player
	var direction_away = (global_transform.origin - player.global_transform.origin).normalized()

	# Set a new target position away from the player using NavigationAgent
	var retreat_target = global_transform.origin + (direction_away * speed * 2)  # Move farther away (adjust multiplier as needed)
	nav_agent.set_target_position(retreat_target)
	var next_nav_point = nav_agent.get_next_path_position()

	# Calculate velocity away from the player
	velocity = (next_nav_point - global_transform.origin).normalized() * speed
	move_and_slide()

	# Look away from the player
	look_at(player.global_transform.origin, Vector3.UP)
	rotation.y += PI  # Reverse to face away from the player


func melee_attack():
	canChangeState = false
	if !attack_timer.is_stopped():
		return
	attack_timer.start()
	setAnimationParamsToZero()
	animation_tree.set("parameters/Attack/blend_amount", 1)

func strafe():
	# Play strafing animations and adjust velocity for actual movement
	if strafe_stage == 0:
		#print("STRAFE STAGE IS 0")

		setAnimationParamsToZero()
		animation_tree.set("parameters/Strafe/blend_amount", 1)
		velocity = -perpendicular_dir * speed  # Move left relative to player

	elif strafe_stage == 1:
		#print("STRAFE STAGE IS 1")
		setAnimationParamsToZero()
		animation_tree.set("parameters/Strafer/blend_amount", 1)
		velocity = perpendicular_dir * speed  # Move right relative to player

func low_health_behavior():
	# Attempt to heal if a healing card is available
	var healing_card = find_card_by_type("heal")
	if healing_card != null:
		play_spell_card(healing_card)
		hand.erase(healing_card)
		return  # Exit after playing a healing card
		
func target_low_health_behavior():
	# Implement aggressive targeting behavior here
	pass

func jump_behavior():
	if jump_stage == 0 and is_on_floor():
		var direction_to_player = (player.global_transform.origin - global_transform.origin).normalized()
		velocity = direction_to_player * speed  # Apply horizontal speed towards the player
		velocity.y = 10  # Initial vertical jump velocity
		set_jump_animation("J")  # Start jump animation
		jump_stage = 1
	elif jump_stage == 1:
		if velocity.y > 0:  # Moving upward
			set_jump_animation("Ju")
			jump_stage = 2
	elif jump_stage == 2:
		if velocity.y <= 0:  # At peak or falling
			set_jump_animation("Jum")
			jump_stage = 3
	elif jump_stage == 3:
		if !is_on_floor():  # Falling
			set_jump_animation("Jump")
		elif is_on_floor():  # Landed
			set_jump_animation("Jumps")  # Hard landing
			jump_stage = 0  # Reset the jump stage after landing

func set_jump_animation(animation_name: String):
	setAnimationParamsToZero()
	animation_tree.set("parameters/%s/blend_amount" % animation_name, 1)


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


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "zDSDASD-noexp":
		shoot.play()
		canChangeState = true
		setAnimationParamsToZero()

	print(anim_name)



func _on_step_timer_timeout() -> void:
	step.play()
	pass # Replace with function body.


func playRecursion():
	play_monster_card(recursionCard)
	pass

var level: int
#var attack: int
var defense: int
var archetype: String
var monster_name: String
var scene_path: String = "res://scenes/robot.tscn"

func setupAttributes(metadata:CardMetaData) -> void:
	self.level = metadata.level
	self.attack = metadata.card_attack
	self.defense = metadata.card_hp
	self.archetype = metadata.archetype
	self.monster_name = metadata.card_name
	self.scene_path = metadata.scene_path
func spawnMonster( player: Node, current_scene: Node, distance: float = 5.0, scale: Vector3 = Vector3(1, 1, 1), recursion_level:float=1,) -> void:
	# Load the scene and check if it's a valid PackedScene
	self.health = recursion_level*100
	self.attack = recursion_level*20
	var cards_to_remove = min(self.deck.size(), int(recursion_level))  # Remove up to `recursion_level` cards, but not more than the deck size
	for i in range(cards_to_remove):
		self.deck.pop_back() 
	self.recursionLevel-=0.2
	var monster_scene = load(scene_path)
	if monster_scene == null:
		print("Failed to load monster scene!")
		return
	if not monster_scene is PackedScene:
		print("Loaded resource is not a valid PackedScene!")
		return
	# Instance the monster from the PackedScene
	var monster = monster_scene.instantiate()
	if monster == null:
		print("Failed to instance monster!")
		return
	# Add the monster to the current scene before modifying its transform
	if current_scene != null:
		current_scene.add_child(monster)
		print("Spawned monster: " + monster_name)
	else:
		print("No valid scene to spawn the monster!")
		return

	print("our attributes for this monster are", level, attack, defense)
	# Defer setting the transform to avoid the "is_inside_tree()" error
	monster.call_deferred("set_transform", Transform3D(monster.transform.basis, player.get_global_transform().origin + player.get_global_transform().basis.z.normalized() * -distance))

	# Apply the scale after the monster is added to the scene
	monster.scale = scale
	
func nerfSelf(recursion_level:float):
		health = 100*recursion_level
		recursionLevel-= 0.3
		attack = 20*recursionLevel
		print("after nerfing our health is: ", self.health)
		print("after nerfing our recursion level is: ", self.recursionLevel)
		var cards_to_remove = min(self.deck.size(), int(recursion_level))  # Remove up to `recursion_level` cards, but not more than the deck size
		for i in range(cards_to_remove):
			deck.pop_back() 
