extends Node3D

@onready var player: CharacterBody3D = $NavigationRegion3D/Player
@onready var robot: CharacterBody3D = $NavigationRegion3D/Robot
@onready var navigation_region_3d: NavigationRegion3D = $NavigationRegion3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DeckManager.playerLocal = player
	AiDeckManager.playerLocal = robot
	AiDeckManager.setNavAgent(navigation_region_3d)
	print("we set player to: ", player, "and robot to: ", robot, "and nav agent to: ", navigation_region_3d)
	pass # Replace with function body.
