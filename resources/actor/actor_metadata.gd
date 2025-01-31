class_name ActorMetadata extends Resource

@export var _actor_name: String
@export_multiline var _actor_description: String
@export var _actor_level: int

func get_actor_name() -> String:
	return _actor_name
func get_actor_description() -> String:
	return _actor_description
func get_actor_level() -> int:
	return _actor_level
