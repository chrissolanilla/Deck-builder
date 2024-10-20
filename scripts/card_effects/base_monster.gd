extends Node
class_name BaseMonster

var level: int
var attack: int
var defense: int
var archetype: String
var name: String
var model_path: String

func setupAttributes(metadata:CardMetaData) -> void:
	self.level = metadata.level
	self.attack = metadata.card_attack
	self.defense = metadata.card_hp
	self.archetype = metadata.archetype
	self.name = metadata.card_name
	self.model_Path = metadata.model_path

func spawnMonser(location: Vector3) -> void:
	# how do i spawn a monster in front of the player?
	pass

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
	name = newName

func changeLevel(newLevel: int) -> void:
	level = newLevel
