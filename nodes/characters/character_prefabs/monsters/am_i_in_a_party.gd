extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor = actor as Character
	
	if not actor.has_node("CharacterPartyReference"):
		return FAILURE
	
	var party_reference = actor.get_node("CharacterPartyReference")
	
	if party_reference.is_in_party():
		return SUCCESS
	return FAILURE
