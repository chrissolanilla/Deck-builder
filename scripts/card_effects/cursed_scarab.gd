extends BaseMonster

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var move_speed = 2.0
var gravity = -9.8

# Time in seconds between direction changes
var direction_change_interval = 2.0
var time_since_direction_change = 0.0

var current_direction = Vector3.ZERO

func _ready():
	print("Cursed Scarab ready!")
	animation_player.play("IdleSpider")

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Update the timer for direction change
	time_since_direction_change += delta
	if time_since_direction_change >= direction_change_interval:
		# Choose a new random direction
		current_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		time_since_direction_change = 0.0  # Reset the timer

	# Apply the current direction to movement
	velocity.x = current_direction.x * move_speed
	velocity.z = current_direction.z * move_speed
	move_and_slide()

	# Rotate the spider to face the current movement direction
	if current_direction.length() > 0:
		# Calculate the rotation angle on the Y axis
		var target_rotation_y = atan2(current_direction.x, current_direction.z)
		rotation.y = target_rotation_y

	# Play the walking or idle animation based on movement
	if current_direction.length() > 0:
		animation_player.play("WalkSpider")
	else:
		animation_player.play("IdleSpider")
