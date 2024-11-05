extends Node
class_name BaseSpell

var archetype: String
var spell_name: String
var portrait: Texture
var start_up: float
var is_interrupted: bool = false
var playerLocal: CharacterBody3D
var initialized:bool = false
signal attributes_initialized

func setupAttributes(metadata: CardMetaData) -> void:
	self.archetype = metadata.archetype
	self.spell_name = metadata.card_name
	self.portrait = metadata.card_portrait
	print("setting attributes. before self.startup is ", self.start_up)
	self.start_up = metadata.card_start_up
	print("after self.startup is ", self.start_up)
	emit_signal("attributes_initialized")

func activate_spell(player: CharacterBody3D, spell_card: CardMetaData, current_scene: Node, distance: float, scale: Vector3 = Vector3(1, 1, 1)) -> void:
	if not initialized:
		print("Attributes not initialized. Waiting for setupAttributes() to complete.")
		await self.attributes_initialized
	print("Activating spell: ", spell_name)

	playerLocal = player
	var spell_scene = load("res://scenes/World_spell_card.tscn")
	var spell_instance = spell_scene.instantiate()
	var spell = load(spell_card.script_path)
	if player.name=="Player":
		DeckManager.setCurrentCardInstance(spell_instance)
	else:
		AiDeckManager.setCurrentCardInstance(spell_instance)
	change_sprite(spell_instance, portrait)

	if current_scene == null:
		print("Scene is null!")
		return

	current_scene.add_child(spell_instance)
	spell_instance.scale = scale

	var audio_player = spell_instance.get_node("AudioStreamPlayer3D")
	if audio_player:
		audio_player.play()
	var spell_position = player.get_global_transform().origin + player.get_global_transform().basis.z.normalized() * -distance
	spell_position.y += 5.0  # Adjust this value to set how high off the ground it should be
	spell_instance.call_deferred("set_transform", Transform3D(spell_instance.transform.basis, spell_position))

	# Start the countdown using DeckManager
	print("passing these into function: self is ", self, "palyer is: ", player, "startup is  ", self.start_up)
	print("player.name is ", player.name)
	if player.name == "Player":
		print("doing the thing for player")
		DeckManager.startCountDown(self, player, self.start_up)
	else:
		print("doing the thing for the robot")
		AiDeckManager.startCountDown(self,player,self.start_up)

func resolve_spell(player: CharacterBody3D) -> void:
	if not initialized:
		return
	print("Base spell resolve - should be overridden.")

func change_sprite(spell_instance, portrait):
	print("helloa")
	#print("spell instance is", spell_instance)
	var backside = spell_instance.get_node("backside")
	var front = spell_instance.get_node("front")
	front.texture = portrait
	backside.texture = portrait
	
