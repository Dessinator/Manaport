extends ActionLeaf

@export var _patrol_range_name: String

var _patrol_range: CharacterPatrolRange
var _com_input_manager: CharacterCOMInputManager

func before_run(actor: Node, blackboard: Blackboard):
	if _patrol_range == null:
		_patrol_range = blackboard.get_node(blackboard.get_value(_patrol_range_name))
	if _com_input_manager == null:
		_com_input_manager = blackboard.get_node(blackboard.get_value("com_input_manager"))

func tick(actor: Node, blackboard: Blackboard) -> int:
	var target = _patrol_range.generate_random_target()
	_com_input_manager.set_target_node(target)
	
	return SUCCESS
