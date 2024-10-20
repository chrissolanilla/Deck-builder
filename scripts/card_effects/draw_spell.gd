extends BaseSpell

func resolve_spell(player: CharacterBody3D) -> void:
	# Access the player's deck or hand and draw one card
	var drawn_card = DeckManager.draw_card()
	if drawn_card != null:
		# Add the drawn card to the player's hand and update the UI
		player.hand.append(drawn_card)
		player.card_container._update_card_visuals()
		print("Player drew a card: " + drawn_card.card_name)
	else:
		print("No cards left in the deck!")
