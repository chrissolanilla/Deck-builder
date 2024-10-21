extends CharacterBody3D

# Speed of the enemy
var speed = 2.0

@onready var nav_agent = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Player"

func _physics_process(delta):
	if player:
		var direction = (player.global_transform.origin - global_transform.origin).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		print("Player not found")
