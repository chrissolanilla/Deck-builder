extends RigidBody3D

# Speed of the bullet
var speed = 20.0

func _ready():
	# Set the bullet to be removed after 3 seconds
	await get_tree().create_timer(3).timeout
	queue_free()

func _physics_process(delta):
	# Move the bullet forward
	position *= transform.basis * Vector3(0, 0, speed) * delta
