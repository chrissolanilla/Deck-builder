extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.0010
var health = 100
var attack = 20
var card_container;
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	card_container = get_parent().get_node("CardContainer")
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

# Function to handle keyboard input
func _input(event: InputEvent) -> void:
	# Check if the event is a key press and a number key is pressed
	if event is InputEventKey and event.pressed:
		# Handle number keys (1-7)
		match event.keycode:
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7:
				var index = event.keycode - KEY_1  # Get index from 0-6
				select_card_by_index(index)

# Function to select a card by its index
func select_card_by_index(index: int) -> void:
	print("selected index %s" % index)
	if index >= 0 and index < card_container.cards.size():
		var selected_card = card_container.cards[index]
		if selected_card.card_name == "Rage":
			attack *= 2
			await get_tree().create_timer(5).timeout
			attack /= 2
		elif selected_card.card_name == "Heal":
			health  += min(health + 30, 100)
		elif selected_card.card_name == "Draw":
			card_container.cards.append(card_container.card_files[randf_range(0, 4)])
			print(card_container.cards)
		card_container.cards.remove_at(index)
		card_container._update_card_visuals()
	else:
		print("Invalid card index")
	
