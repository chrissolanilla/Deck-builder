extends BaseSpell
class_name RecursionSpell

# Path to the Robot scene (adjust to your actual file structure)
const ROBOT_SCENE_PATH = "res://scenes/robot.tscn"

func resolve_spell(player: CharacterBody3D, enemy: CharacterBody3D = null) -> void:
	player.playRecursion()
