extends Node3D
@onready var sparks: GPUParticles3D = $Sparks
@onready var flare: GPUParticles3D = $Flare

func spark():
	sparks.emitting = true
	flare.emitting = true
	await get_tree().create_timer(2).timeout
	queue_free()
