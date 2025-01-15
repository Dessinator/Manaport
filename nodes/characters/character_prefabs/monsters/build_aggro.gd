extends ActionLeaf

var _aggro_manager: CharacterAggroManager

func before_run(actor: Node, blackboard: Blackboard):
	if _aggro_manager == null:
		_aggro_manager = blackboard.get_node(blackboard.get_value("aggro_manager"))

func tick(actor: Node, blackboard: Blackboard) -> int:
	_aggro_manager.build_aggro(actor.get_physics_process_delta_time())
	
	if _aggro_manager.get_aggro() < 100.0:
		return RUNNING
	
	return SUCCESS
