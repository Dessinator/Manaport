extends ActionLeaf

@export var _party_name: String

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor = actor as Character
	
	if not blackboard.has_value(_party_name):
		return FAILURE
	
	var party = blackboard.get_value(_party_name)
	
	if not actor.has_node("CharacterPartyReference"):
		return FAILURE
	
	var party_reference = actor.get_node("CharacterPartyReference")
	party_reference.join_party(party)
	
	return SUCCESS
