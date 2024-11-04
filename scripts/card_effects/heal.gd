extends BaseSpell

func resolve_spell(player: CharacterBody3D) -> void:
	player.health = min(100, player.health + 20)
	player.healthbar.value = player.health
