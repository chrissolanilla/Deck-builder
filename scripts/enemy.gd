extends CharacterBody3D

# Speed of the enemy
var gravity = -9.8
var speed = 2.0
var health = 100
@onready var nav_agent = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Player"
@onready var healthbar: ProgressBar = $SubViewport/Healthbar

func _physics_process(delta):
	if player:
		var direction = (player.global_transform.origin - global_transform.origin).normalized()
		velocity = direction * speed
		#make him fall in gravity.
		if not is_on_floor():
			velocity.y += gravity * delta*10 #needs to be a high value lowkey
		else:
			velocity.y = 0
		
		move_and_slide()
		# Rotate the enemy to face the player
		var look_at_position = player.global_transform.origin
		look_at(look_at_position, Vector3.UP)
		rotation.y += PI
	else:
		print("Player not found")

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
		
