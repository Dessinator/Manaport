extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_node(blackboard.get_value("aggro_manager")).get_aggro() > 0.0:
		return SUCCESS
	else:
		return FAILURE
