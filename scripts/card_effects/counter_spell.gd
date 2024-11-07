extends BaseSpell


func resolve_spell(player: CharacterBody3D, enemy: CharacterBody3D = null) -> void:
	#
	#if not initialized:
		#print("Attributes not initialized. Waiting for setupAttributes() to complete.")
		#await self.attributes_initialized
	#print("we finished")
	var audio_player = player.get_node("AudioStreamPlayer3D")
	if audio_player:
		audio_player.play()
	else:
		print("AudioStreamPlayer3D node not found")
		
	print("calling negate function")
	if player.name == "Player":
		AiDeckManager.negateCurrentCard()
	else:
		DeckManager.negateCurrentCard()
		
	
