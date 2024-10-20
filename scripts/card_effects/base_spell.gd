extends Node
class_name BaseSpell

var archetype: String
var spell_name: String
var portrait: Texture
var start_up: float
var is_interrupted: bool = false
var playerLocal: CharacterBody3D

func setupAttributes(metadata: CardMetaData) -> void:
	self.archetype = metadata.archetype
	self.spell_name = metadata.card_name
	self.portrait = metadata.card_portrait
	self.start_up = metadata.card_start_up

func activate_spell(player: CharacterBody3D, spell_card: CardMetaData, current_scene: Node, distance: float, scale: Vector3 = Vector3(1, 1, 1)) -> void:
	print("Activating spell: ", spell_name)

	playerLocal = player
	var spell_scene = load("res://scenes/World_spell_card.tscn")
	var spell_instance = spell_scene.instantiate()
	var backside = spell_instance.get_node("backside")
	var front = spell_instance.get_node("front")
	front.texture = portrait
	backside.texture = portrait

	if current_scene == null:
		print("Scene is null!")
		return

	current_scene.add_child(spell_instance)
	spell_instance.scale = scale

	var audio_player = spell_instance.get_node("AudioStreamPlayer3D")
	if audio_player:
		audio_player.play()

	spell_instance.call_deferred("set_transform", Transform3D(spell_instance.transform.basis, player.get_global_transform().origin + player.get_global_transform().basis.z.normalized() * -distance))

	# Start the countdown using DeckManager
	DeckManager.startCountDown(self, player, start_up)

func resolve_spell(player: CharacterBody3D) -> void:
	print("Base spell resolve - should be overridden.")
