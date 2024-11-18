extends BaseSpell
const SMOKE = preload("res://scenes/smoke.tscn")
func resolve_spell(player: CharacterBody3D, enemy: CharacterBody3D = null) -> void:
	#spawn a big cloud and have it move to a player
	var smoke = SMOKE.instantiate()
	var distance = 12
	current_scene.add_child(smoke)
	var spell_position = player.get_global_transform().origin + player.get_global_transform().basis.z.normalized() * -distance
	spell_position.y -= 2.0  # Adjust this value to set how high off the ground it should be
	smoke.call_deferred("set_transform", Transform3D(smoke.transform.basis, spell_position))
