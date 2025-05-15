extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	if not blackboard.has_value("enemy"):
		return FAILURE
	
	var cached_enemy = blackboard.get_value("enemy")
	
	if not cached_enemy.has_node("CharacterPartyReference"):
		return FAILURE
	
	var cached_enemy_party_reference = cached_enemy.get_node("CharacterPartyReference")
	
	return SUCCESS
