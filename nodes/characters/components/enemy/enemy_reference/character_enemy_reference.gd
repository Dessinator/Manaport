class_name CharacterEnemyReference
extends Node

var _id: int

func _ready() -> void:
	_id = _add_self_to_overworld_global_enemy_array()

# returns this enemy's index in the global enemy array 
func _add_self_to_overworld_global_enemy_array() -> int:
	return OverworldManager.add_enemy_to_global_enemy_array(self)

func get_id() -> int:
	return _id
