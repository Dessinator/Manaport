class_name CharacterBattleHandler extends Node3D

signal battle_started

@export var _actor_scenes: Array[PackedScene]

# if true, this Character can also start a battle with another Character.
@export var _can_start_battle: bool

var _is_in_battle: bool = false

# will start a battle with opponent.
# be called on aggressor.
func start_battle(opponent: CharacterBattleHandler):
	print("start battle!")
	_is_in_battle = true
	opponent.encounter(self)
	
	BattleManager.start_battle(self, opponent)

# called on opponent by aggressor.
func encounter(opponent: CharacterBattleHandler):
	_is_in_battle = true

func is_in_battle() -> bool:
	return _is_in_battle
	
func get_actor_scenes() -> Array[PackedScene]:
	return _actor_scenes
