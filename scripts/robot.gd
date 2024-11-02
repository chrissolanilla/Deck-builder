extends CharacterBody3D

# Speed of the enemy
var gravity = -9.8
var speed = 2.0
var health = 100
var deck: Array[CardMetaData]
@onready var nav_agent = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../Player"
@onready var healthbar: ProgressBar = $SubViewport/Healthbar
@onready var bullet = load("res://scenes/bullet.tscn")
@onready var robot_body = $"PlayerModel/Robot_Skeleton/Skeleton3D/00Robot_Body_008"
var instance

func _ready() -> void:
	deck.shuffle()
	

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
