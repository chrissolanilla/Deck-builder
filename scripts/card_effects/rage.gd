extends BaseSpell

@export var duration := 2.0

func resolve_spell(player: CharacterBody3D) -> void:
	print(player.attack)
	player.attack *= 2
	
	# Create a timer node to handle the delay
	var revert_timer = Timer.new()
	revert_timer.wait_time = duration
	revert_timer.one_shot = true
	player.add_child(revert_timer)
	revert_timer.start()
	
	# Wait for the timer to finish
	await revert_timer.timeout
	
	# Revert the attack power back to normal
	player.attack /= 2
	
	# Remove the timer node after use
	revert_timer.queue_free()
