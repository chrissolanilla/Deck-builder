extends Node3D
class_name BaseMonster

var level: int
var attack: int
var defense: int
var archetype: String
var monster_name: String
var scene_path: String

func setupAttributes(metadata:CardMetaData) -> void:
	self.level = metadata.level
	self.attack = metadata.card_attack
	self.defense = metadata.card_hp
	self.archetype = metadata.archetype
	self.monster_name = metadata.card_name
	self.scene_path = metadata.scene_path

func spawnMonster(player: Node, current_scene: Node, distance: float = 5.0) -> void:
	# Load the scene and check if it's a valid PackedScene
	var monster_scene = load(scene_path)
	if monster_scene == null:
		print("Failed to load monster scene!")
		return
	if not monster_scene is PackedScene:
		print("Loaded resource is not a valid PackedScene!")
		return

	# Instance the monster from the PackedScene
	var monster = monster_scene.instantiate()
	if monster == null:
		print("Failed to instance monster!")
		return

	# Position the monster in front of the player
	var forward = player.get_global_transform().basis.z.normalized() * -1
	var spawn_position = player.get_global_transform().origin + forward * distance
	monster.global_transform.origin = spawn_position

	# Add the monster to the scene passed as an argument
	if current_scene != null:
		current_scene.add_child(monster)
		print("Spawned monster: " + monster_name)
	else:
		print("No valid scene to spawn the monster!")



func takeDamage(amount: int) -> void:
	#should i make it like yugioh(they dont lose health) or like heartstone?
	defense -= amount
	if defense <= 0:
		destroyByBattle()
	pass

func destroyByBattle() -> void:
	#how do i remove it from the field and send it to the players graveyard?
	pass

func banish()-> void:
	#how do i send it to the players banished zone
	pass

func heal(amount: int) -> void:
	defense += amount

func reduceAttack(amount: int) -> void:
	attack -= amount

func increaseAttack(amount: int) -> void:
	attack += amount

func changeName(newName: String) -> void:
	monster_name = newName

func changeLevel(newLevel: int) -> void:
	level = newLevel
