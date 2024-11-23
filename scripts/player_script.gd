extends CharacterBody3D
var original_mouse_sensitivity = MOUSE_SENSITIVITY
const SPEED = 5.0
const JUMP_VELOCITY = 7.5
var MOUSE_SENSITIVITY = 0.0010
const DRAW_INTERVAL = 15
@onready var healthbar: ProgressBar = $Healthbar
@onready var enemy: CharacterBody3D = $"../Robot"
var wobble_timer: Timer
var wobble_intensity = 0.05  # How strong the wobble is
var wobble_frequency = 5.0  # Frequency of the wobble effect (how fast it oscillates)
var wobble_elapsed_time = 0.0
var health = 100
var attack = 20
var card_container;
var deck: Array[CardMetaData]
var hand: Array[CardMetaData]
#timer created programatically
var draw_timer: Timer
var bullet = load("res://scenes/bullet.tscn")
var instance
@onready var wobleTimer: Timer = $Camera3D/Timer
var rifle: Node3D
var rifle_anim: AnimationPlayer
var rifle_barrel:RayCast3D
var disoriented:bool

func _process(_delta: float) -> void:
	if Input.is_action_pressed("toggleMouse"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#if Input.is_action_pressed("shoot"):
	if health <= 0:
		#put up a game over menu maybe
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		self.queue_free()
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	card_container = get_parent().get_node("CardContainer")
	#on ready we load the deck from the game file
	deck = DeckManager.loadCurrentDeck(deck)  # Correcting the singleton call
	DeckManager.setDeck(deck)
	DeckManager.shuffle()
	#draw 5 cards in the start of the game into the players hud
	for i in range(5):
		hand.append(DeckManager.draw_card())
	DeckManager.setHand(hand)
	#start a recurring timer to draw a card every 15 seconds
	draw_timer = Timer.new()
	add_child(draw_timer)
	draw_timer.wait_time = DRAW_INTERVAL
	draw_timer.connect("timeout", Callable(self, "_on_draw_timer_timeout"))
	draw_timer.start()
	#set the hand in the hotbar
	card_container.cards = hand

	# Get the Rifle node
	rifle = $Camera3D/Rifle
	rifle_anim = $Camera3D/Rifle/AnimationPlayer
	rifle_barrel = $Camera3D/Rifle/RayCast3D

#draw every 15 seconds
# Draw a card every 15 seconds
func _on_draw_timer_timeout() -> void:
	print("Drawing for turn")
	var drawn_card = DeckManager.draw_card()
	if drawn_card != null:  # Only append if there's a valid card to draw
		hand.append(drawn_card)
		# card_container.cards = hand  # Update the hotbar's cards
		card_container._update_card_visuals()  # Refresh visuals

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		_head_look(-event.relative)

func _head_look(motion:Vector2):
	var camera = $Camera3D
	camera.rotation.x = clamp(camera.rotation.x + motion.y * MOUSE_SENSITIVITY, -PI / 2 , PI / 2)
	rotate_y(motion.x * MOUSE_SENSITIVITY)
	camera.orthonormalize()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	if Input.is_action_pressed("shoot"):
		if !rifle_anim.is_playing():
			rifle_anim.play("shoot")
			instance = bullet.instantiate()
			instance.position = rifle_barrel.global_position
			instance.transform.basis = rifle_barrel.global_transform.basis
			instance.direction = instance.transform.basis * Vector3(0, 0, -SPEED)
			get_parent().add_child(instance)

# Function to handle keyboard input
func _input(event: InputEvent) -> void:
	# Check if the event is a key press and a number key is pressed
	if event is InputEventKey and event.pressed:
		# Handle number keys (1-7)
		match event.keycode:
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7:
				var index = event.keycode - KEY_1  # Get index from 0-6
				select_card_by_index(index)

func select_card_by_index(index: int) -> void:
	if index >= 0 and index < card_container.cards.size():
		var selected_card = card_container.cards[index]
		if selected_card.card_type == "monster":
			# Load the scarab's script and create an instance
			var monster_script = load(selected_card.script_path)
			print("spell script is", monster_script)
			if monster_script != null:
				var monster_instance = monster_script.new()
				monster_instance.setupAttributes(selected_card)
				var current_scene = get_tree().root.get_child(0)  # Get the root scene manually since its null when i try otherwise
				monster_instance.call_deferred("spawnMonster", self, current_scene, 5.0, Vector3(0.1, 0.1, 0.1))

				# monster_instance.spawnMonster(self, current_scene, 5.0, Vector3(0.1, 0.1, 0.1))  # the last param is the scale of the monster

		elif selected_card.card_type == "spell":
			if DeckManager.getIfSpellActive():
				print("Can not play spell yet")
				return
			#load the script of the spell and create the instance(sprite) above the players head
			var spell_script = load(selected_card.script_path)
			print("spell script is", spell_script)
			if spell_script == null:
				return
			var spell_instance = spell_script.new()
			var current_scene = get_tree().root.get_child(0)
			spell_instance.activate_spell(self, enemy, selected_card, current_scene, 5.0, Vector3(1,1,1))
			#spell_instance.resolve_spell(self, enemy)
			spell_instance.setupAttributes(selected_card)

		# Handle other card types (spells, traps) similarly
		card_container.cards.remove_at(index)
		card_container._update_card_visuals()
	else:
		print("Invalid card index")


func take_damage(amount:int):
	$Camera3D.isHit = true
	wobleTimer.start()
	if amount > health:
			amount = health
	$Camera3D.add_trauma(amount / 50.0)
	health-=amount
	healthbar.value = health
	
func disorient(duration: float) -> void:
	if disoriented:
		return

	disoriented = true
	original_mouse_sensitivity = MOUSE_SENSITIVITY  # Store original sensitivity
	MOUSE_SENSITIVITY *= 0.1  # Reduce sensitivity to make looking delayed/sluggish

	# Start a Timer to end the disorientation after `duration` seconds
	var disorient_timer = Timer.new()
	add_child(disorient_timer)
	disorient_timer.wait_time = duration
	disorient_timer.one_shot = true
	disorient_timer.connect("timeout", Callable(self, "_on_disorient_timeout"))
	disorient_timer.start()

	# Start the wobble effect
	wobble_elapsed_time = 0.0
	wobble_timer = Timer.new()
	add_child(wobble_timer)
	wobble_timer.wait_time = 0.01  # Update every 10ms to create smooth movement
	wobble_timer.connect("timeout", Callable(self, "_on_wobble_timeout"))
	wobble_timer.start()

	print("Disorienting the player for ", duration, " seconds")

func _on_disorient_timeout() -> void:
	# Reset mouse sensitivity to its original value
	MOUSE_SENSITIVITY = original_mouse_sensitivity
	disoriented = false
	print("Player disorient effect ended")
	
func _on_wobble_timeout() -> void:
	if not disoriented:
		$Camera3D.reset_wobble()
		wobble_timer.stop()
		return

	# Update elapsed time for sine wave calculation
	wobble_elapsed_time += wobble_timer.wait_time

	# Calculate sine wave offsets
	var wobble_x = sin(wobble_elapsed_time * wobble_frequency) * wobble_intensity
	var wobble_y = cos(wobble_elapsed_time * wobble_frequency * 0.5) * wobble_intensity

	# Apply wobble to camera rotation
	$Camera3D.add_wobble(wobble_x, wobble_y)


func _on_timer_timeout() -> void:
	$Camera3D.isHit = false
	pass # Replace with function body.
