extends ActionLeaf

const CHARACTER_PATROL_RANGE_SCENE = preload("res://nodes/characters/components/patrol/character_patrol_range.tscn")

@export var _range_name: String
@export var _range_radius: float

func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.has_value(_range_name):
		var range_path = blackboard.get_value(_range_name)
		var range = blackboard.get_node(range_path)
		range.global_position = actor.global_position
		
		return SUCCESS
	
	var range = CHARACTER_PATROL_RANGE_SCENE.instantiate()
	
	range.set_radius(_range_radius)
	add_child(range)
	range.global_position = actor.global_position
	var path = blackboard.get_path_to(range)
	blackboard.set_value(_range_name, path)
	
	return SUCCESS
