extends BaseSpell

func resolve_spell(player: CharacterBody3D, enemy: CharacterBody3D = null) -> void:
	var explosion_scene = load("res://scenes/explosion.tscn")
	if explosion_scene:
		var explosion_instance = explosion_scene.instantiate()
		explosion_instance.global_transform.origin = enemy.global_transform.origin
		player.get_tree().current_scene.add_child(explosion_instance)
		explosion_instance.explode()
		if enemy.has_method("take_damage"):
			enemy.take_damage(30)
