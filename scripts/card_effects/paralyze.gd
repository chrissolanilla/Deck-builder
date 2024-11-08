extends BaseSpell

func resolve_spell(player: CharacterBody3D, enemy: CharacterBody3D = null) -> void:
	var sparks_scene = load("res://scenes/sparks.tscn")
	if sparks_scene:
		var sparks_instance = sparks_scene.instantiate()
		sparks_instance.global_transform.origin = enemy.global_transform.origin
		player.get_tree().current_scene.add_child(sparks_instance)
		sparks_instance.spark()
		enemy.set_physics_process(false)
		await player.get_tree().create_timer(3).timeout
		enemy.set_physics_process(true)
