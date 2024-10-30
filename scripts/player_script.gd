extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.0010
const DRAW_INTERVAL = 15

var health = 100
var attack = 20
var card_container;
var deck: Array[CardMetaData]
var hand: Array[CardMetaData]
#timer created programatically
var draw_timer: Timer

var rifle: Node3D

func _process(_delta: float) -> void:
	if Input.is_action_pressed("toggleMouse"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#if Input.is_action_pressed("shoot"):
		

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
	rifle = $Rifle

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
	
	if rifle:
		var offset = Vector3(0, -3.0, -1.0)  # Adjust this offset as needed
		var rifle_pos = global_transform.origin + global_transform.basis.z * offset
		rifle.global_transform.origin = rifle_pos
		rifle.look_at(global_transform.origin + global_transform.basis.z * 10.0)

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
				monster_instance.spawnMonster(self, current_scene, 5.0, Vector3(0.1, 0.1, 0.1))  # the last param is the scale of the monster

		elif selected_card.card_type == "spell":
			#load the script of the spell and create the instance(sprite) above the players head
			var spell_script = load(selected_card.script_path)
			print("spell script is", spell_script)
			if spell_script == null:
				return
			var spell_instance = spell_script.new()
			spell_instance.resolve_spell(self)
			spell_instance.setupAttributes(selected_card)

		# Handle other card types (spells, traps) similarly
		card_container.cards.remove_at(index)
		card_container._update_card_visuals()
	else:
		print("Invalid card index")
