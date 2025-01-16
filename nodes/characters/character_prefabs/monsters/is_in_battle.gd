extends ConditionLeaf


var _battle_handler: CharacterBattleHandler

func before_run(actor: Node, blackboard: Blackboard):
	if _battle_handler == null:
		_battle_handler = blackboard.get_node(blackboard.get_value("battle_handler"))

func tick(actor: Node, blackboard: Blackboard) -> int:
	if _battle_handler.is_in_battle():
		return SUCCESS
	else:
		return FAILURE
