extends ActionLeaf

var _com_input_manager: CharacterCOMInputManager

func before_run(actor: Node, blackboard: Blackboard):
	if _com_input_manager == null:
		_com_input_manager = blackboard.get_node(blackboard.get_value("com_input_manager"))

func tick(actor: Node, blackboard: Blackboard) -> int:
	_com_input_manager.clear_target_node()
	
	return SUCCESS
