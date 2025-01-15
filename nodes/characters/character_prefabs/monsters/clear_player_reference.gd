extends BlackboardEraseAction

func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.has_value("player"):
		blackboard.erase_value("player")
		return SUCCESS
	return FAILURE
