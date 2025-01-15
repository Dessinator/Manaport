extends ActionLeaf

var _patrol_range: CharacterPatrolRange
var _com_input_manager: CharacterCOMInputManager

func tick(actor: Node, blackboard: Blackboard) -> int:
	if _patrol_range == null:
		_patrol_range = blackboard.get_node(blackboard.get_value("patrol_range"))
	if _com_input_manager == null:
		_com_input_manager = blackboard.get_node(blackboard.get_value("com_input_manager"))
	
	if _com_input_manager.has_reached_target() or _com_input_manager.get_target_node() == null:
		var target = _patrol_range.generate_random_target()
		_com_input_manager.set_target_node(target)
		return SUCCESS
	
	return RUNNING
