extends Node3D

@onready var area_3d: Area3D = $Area3D

var target:CharacterBody3D
var team: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent = get_parent()
	if parent.name =="DeckManager":
		target = AiDeckManager.getPlayer()
		team = "player"
		print("we are on team player")
	else:
		target = DeckManager.getPlayer()
		team = "robot"
		print("we are on team robot")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

	
func _on_area_3d_body_entered(body: Node3D) -> void:
	print("body is: ", body.name)
	if team == "player" and body.name =="Robot":
		body.disorient(15)
	elif team =="robot" and body.name == "Player":
		body.disorient(15)


func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
