extends CharacterBody3D
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

#spawn monster with a distance from the player infront of us, and a scale to scale it down(editing the scene didnt chagne it for me ;[
func spawnMonster(player: Node, current_scene: Node, distance: float = 5.0, scale: Vector3 = Vector3(1, 1, 1)) -> void:
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
	# Add the monster to the current scene before modifying its transform
	if current_scene != null:
		current_scene.add_child(monster)
		print("Spawned monster: " + monster_name)
	else:
		print("No valid scene to spawn the monster!")
		return

	print("our attributes for this monster are", level, attack, defense)
	# Defer setting the transform to avoid the "is_inside_tree()" error
	monster.call_deferred("set_transform", Transform3D(monster.transform.basis, player.get_global_transform().origin + player.get_global_transform().basis.z.normalized() * -distance))

	# Apply the scale after the monster is added to the scene
	monster.scale = scale


func takeDamage(amount: int) -> void:
	#should i make it like yugioh(they dont lose health) or like heartstone?
	defense -= amount
	if defense <= 0:
		destroyByBattle()
	pass

func destroyByBattle() -> void:
	#how do i remove it from the field and send it to the players graveyard?
	self.queue_free()
	pass

func banish()-> void:
	#how do i send it to the players banished zone
	pass

func heal(amount: int) -> void:
	defense += amount
	print("new defense is: ", self.defense)

func reduceAttack(amount: int) -> void:
	attack -= amount
	print("new attack is: ", self.attack)

func increaseAttack(amount: int) -> void:
	attack += amount
	print("new attack is: ", self.attack)

func changeName(newName: String) -> void:
	monster_name = newName
	print("new name is: ", self.monster_name)

func changeLevel(newLevel: int) -> void:
	level = newLevel
	print("new level is: ", self.level)
