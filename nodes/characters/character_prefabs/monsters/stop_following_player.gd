extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var com_input_manager = blackboard.get_node(blackboard.get_value("com_input_manager"))
	
	com_input_manager.clear_target_node()
	return SUCCESS
