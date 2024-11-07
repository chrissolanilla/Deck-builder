extends BaseSpell

func resolve_spell(player: CharacterBody3D, enemy: CharacterBody3D = null) -> void:
	# Access the player's deck or hand and draw one card
	var drawn_card = DeckManager.draw_card()
	print("player children are: ", player.get_children())
	var audio_player = player.get_node("AudioStreamPlayer3D")
	if audio_player:
		audio_player.play()
	else:
		print("AudioStreamPlayer3D node not found")
		
	if drawn_card != null:
		# Add the drawn card to the player's hand and update the UI
		player.hand.append(drawn_card)
		player.card_container._update_card_visuals()
		print("Player drew a card: " + drawn_card.card_name)
	else:
		print("No cards left in the deck!")
