extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var detection_range = blackboard.get_node(blackboard.get_value("detection_range"))
	var overlapping_bodies = detection_range.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if not body.has_node("CharacterPartyReference"):
			continue
		
		var character_party_reference = body.get_node("CharacterPartyReference")
		
		if not character_party_reference.is_in_party():
			continue
		
		var party = character_party_reference.get_current_party()
		
		if not party.is_in_group("player_party"):
			continue
		
		if character_party_reference.is_party_leader():
			blackboard.set_value("player", body)
			return SUCCESS
	return FAILURE
