extends Node3D

const SPEED = 40.0
@export var direction: Vector3 = Vector3.ZERO
@onready var mesh = $BulletArea/MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * SPEED * delta
	if ray.is_colliding():
		mesh.visible = false
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()

#TODO
#this code didnt work cause the bullet would go through the robot for some reason TODO!!!!
func _on_area_3d_body_entered(body: Node3D) -> void:
	var damage = DeckManager.getAttack()
	if body.has_method("take_damage"):
		body.take_damage(damage)
