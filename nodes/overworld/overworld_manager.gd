class_name OverworldManager extends Node3D

static var _instance: OverworldManager

var _is_battle_active: bool
var _active_battle_stage_instance: StageManager

@onready var _environment_instance: Node = %Environment
@onready var _player_party: Node = %PlayerParty

func _enter_tree():
	if _instance:
		return
	
	_instance = self
