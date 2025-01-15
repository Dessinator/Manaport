extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var com_input_manager = blackboard.get_node(blackboard.get_value("com_input_manager"))
	var player = blackboard.get_value("player")
	
	com_input_manager.set_target_node(player)
	return SUCCESS
