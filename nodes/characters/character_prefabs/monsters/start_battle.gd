extends ActionLeaf

var _battle_handler: CharacterBattleHandler

func before_run(actor: Node, blackboard: Blackboard):
	if _battle_handler == null:
		_battle_handler = blackboard.get_node(blackboard.get_value("battle_handler"))

func tick(actor: Node, blackboard: Blackboard) -> int:
	var player = blackboard.get_value("player")
	if player == null:
		return FAILURE
	
	var player_battle_handler = player.get_node("CharacterBattleHandler")
	if player_battle_handler == null:
		return FAILURE
	
	_battle_handler.start_battle(player_battle_handler)
	
	return SUCCESS
