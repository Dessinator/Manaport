extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor = actor as Character
	
	if not actor.has_node("CharacterEnemyReference"):
		return FAILURE
	
	var my_enemy_reference = actor.get_node("CharacterEnemyReference")
	
	if not blackboard.has_value("enemy"):
		return FAILURE
	
	var cached_enemy = blackboard.get_node(blackboard.get_value("enemy"))
	
	if not cached_enemy.has_node("CharacterEnemyReference"):
		return FAILURE
	
	var other_enemy_reference = cached_enemy.get_node("CharacterEnemyReference")
	
	var my_id = my_enemy_reference.get_id()
	var other_id = other_enemy_reference.get_id()
	
	if my_id < other_id:
		return SUCCESS
	return FAILURE
