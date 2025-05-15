extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var dynamic_party_range = blackboard.get_node(blackboard.get_value("dynamic_party_range"))
	var overlapping_bodies = dynamic_party_range.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.has_node("CharacterEnemyReference"):
			return SUCCESS
		
		var character_enemy_reference = body.get_node("CharacterEnemyReference")
		blackboard.set_value("enemy", character_enemy_reference)
	return FAILURE
