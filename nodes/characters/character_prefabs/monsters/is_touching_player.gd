extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var last_slide_collision = actor.get_last_slide_collision()
	var collided = last_slide_collision.get_collider()
	
	if collided == blackboard.get_value("player"):
		return SUCCESS
	return FAILURE
