extends ActionLeaf

@export var _party_name: String

func tick(actor: Node, blackboard: Blackboard) -> int:
	var party = OverworldManager.create_party()
	blackboard.set_value(_party_name, party)
	
	return SUCCESS
