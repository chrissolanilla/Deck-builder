extends CharacterBody3D

# Speed of the enemy
var gravity = -9.8
var speed = 2.0

@onready var nav_agent = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Player"

func _physics_process(delta):
	if player:
		var direction = (player.global_transform.origin - global_transform.origin).normalized()
		velocity = direction * speed
		#make him fall in gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.y = 0
		
		move_and_slide()
		# Rotate the enemy to face the player
		var look_at_position = player.global_transform.origin
		look_at(look_at_position, Vector3.UP)
		rotation.y += PI
	else:
		print("Player not found")
