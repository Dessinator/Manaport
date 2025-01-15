extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_node(blackboard.get_value("aggro_manager")).is_aggroed():
		return SUCCESS
	else:
		return FAILURE
