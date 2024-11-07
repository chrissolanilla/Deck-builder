extends BaseSpell

func resolve_spell(player: CharacterBody3D, enemy: CharacterBody3D = null) -> void:
	player.health = min(100, player.health + 20)
	player.healthbar.value = player.health
