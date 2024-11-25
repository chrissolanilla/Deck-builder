extends BaseSpell
class_name RecursionSpell

# Path to the Robot scene (adjust to your actual file structure)
const ROBOT_SCENE_PATH = "res://scenes/robot.tscn"

func resolve_spell(player: CharacterBody3D, enemy: CharacterBody3D = null) -> void:
	if not initialized:
		return

	print("Resolving Recursion Spell - Spawning a new robot.")

	# Load the robot scene
	var robot_scene = load(ROBOT_SCENE_PATH)
	if robot_scene == null:
		print("Failed to load robot scene.")
		return

	# Instance the robot
	var new_robot = robot_scene.instantiate()
	if new_robot == null:
		print("Failed to instance robot!")
		return

	# Add the robot to the current scene
	if current_scene != null:
		current_scene.add_child(new_robot)
		print("New robot added to the scene.")
	else:
		print("Current scene is null! Cannot spawn the robot.")
		return

	# Set the robot's initial position near the player
	var spawn_position = player.global_transform.origin + Vector3(randf() * 10 - 5, 0, randf() * 10 - 5)
	new_robot.global_transform.origin = spawn_position

	# Perform any additional initialization for the robot here
	print("Spawned robot at position: ", spawn_position)
