class_name ActSelector extends Control

signal act_selected(act: Act)

const ACT_BUTTON_SCENE = preload("res://nodes/stage/stage_interface/act_button/act_button.tscn")

@export var _stage_interface: StageInterface
@onready var _state_machine: FiniteStateMachine = $FiniteStateMachine
@export var _blackboard: BTBlackboard

@onready var _act_button_container: VBoxContainer = %ActButtonContainer

@onready var _basic_move_button: ActButton = %BasicMoveButton
@onready var _skill_button: ActButton = %SkillButton
@onready var _item_button: ActButton = %ItemButton
@onready var _escape_button: ActButton = %EscapeButton

func _ready():
	_blackboard.set_value("stage_interface", _stage_interface)
	
	_blackboard.set_value("act_button_container", _act_button_container)
	_blackboard.set_value("basic_move_button", _basic_move_button)
	_blackboard.set_value("skill_button", _skill_button)
	_blackboard.set_value("item_button", _item_button)
	_blackboard.set_value("escape_button", _escape_button)
	
	_state_machine.start()

func show_acts(acting_actor: Actor):
	_blackboard.set_value("acting_actor", acting_actor)
	_blackboard.set_value("act_selected", Signal(act_selected))
	_state_machine.fire_event("show_main")

func close_acts():
	_blackboard.remove_value("acting_actor")
	_blackboard.remove_value("act_selected")
	_state_machine.fire_event("hide")

func get_blackboard() -> BTBlackboard:
	return _blackboard
