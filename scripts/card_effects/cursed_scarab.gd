extends BaseMonster


# @onready var navigation_agent = $NavigationAgent3D  # Optional, if you have a NavigationAgent3D for pathfinding
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var move_speed = 2.0

func _ready():
	print("Cursed Scarab ready!")
	animation_player.play("IdleSpider")  # Use the correct animation name
	print("just played idle")

func _physics_process(delta: float) -> void:
	# Move the scarab randomly
	var random_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var movement_vector = random_direction * move_speed * delta

	# Move in random directions
	translate(movement_vector)
	orthonormalize()  # Ensures smooth movement

	# Play walking or idle animations based on movement
	if random_direction.length() > 0:
		print("printing walk")
		animation_player.play("WalkSpider")  # Use the correct walking animation name
	else:
		animation_player.play("IdleSpider")  # Use the correct idle animation name
		print("printing idle")
# Override takeDamage to play death animation and destroy the scarab
func takeDamage(amount: int) -> void:
	defense -= amount
	if defense <= 0:
		animation_player.play("DeathSpider")  # Use the correct death animation name
		destroyByBattle()

func destroyByBattle() -> void:
	queue_free()  # Remove the scarab from the scene
