extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("aggro"):
		return SUCCESS
	else:
		return FAILURE
