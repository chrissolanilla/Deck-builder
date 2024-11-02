extends CharacterBody3D

var health: int
@onready var healthbar: ProgressBar = $SubViewport/Healthbar

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	health = 100
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	move_and_slide()
	
func take_damage(amount:int) -> void:
	if(health< amount):
		amount = health
	health -= amount
	healthbar.value = health
	if(health ==0):
		queue_free()
