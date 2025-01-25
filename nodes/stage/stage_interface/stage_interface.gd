class_name StageInterface extends Control

signal act_selected(act: Act)
# if provided an empty array, will treat the action like
# cancelling target selection.
signal targets_selected(target_actors: Array)

const ACTOR_INFO_SCENE = preload("res://nodes/stage/stage_interface/actor_info/actor_info_card/actor_info_card.tscn")
const MINI_ACTOR_INFO_SCENE = preload("res://nodes/stage/stage_interface/actor_info/mini_actor_info/mini_actor_info.tscn")
const ACTION_ORDER_VISUAL_SCENE = preload("res://nodes/stage/stage_interface/action_order_visual/action_order_visual.tscn")

@onready var _stage: StageManager = $".."
@onready var _state_machine: FiniteStateMachine = $FiniteStateMachine
@export var _blackboard: BTBlackboard

@export var _stage_camera: StageCamera
@export var _ready_camera: Camera3D
@export var _attack_camera: Camera3D
@export var _defend_camera: Camera3D

@onready var _mini_actor_viewport_container = $MiniActorInfoViewportContainer
@onready var _main_container = $MarginContainer
@onready var _inspect_interface_container = $InspectInterface

@onready var _inspect_delay_timer: Timer = $InspectDelayTimer
@onready var _inspect_timer: Timer = $InspectTimer
@onready var _hold_circle: HoldCircle = %HoldCircle

@onready var _mini_actor_info_camera: Camera3D = %MiniActorInfoCamera

@onready var _act_selector: ActSelector = %ActSelector

@onready var _actor_info_container = %ActorInfoCardContainer
@onready var _mini_actor_info_container = %MiniActorInfoContainer
@onready var _action_order_visual_container = %ActionOrderVisualContainer

func _ready():
	_blackboard.set_value("action_order_visuals", [])
	
	_state_machine.start()

func instantiate_actor_info_scene(actor: Actor):
	var instance = ACTOR_INFO_SCENE.instantiate() as ActorInfo
	_actor_info_container.add_child(instance)
	actor.get_visual_manager().attach_actor_info(instance)
func instantiate_mini_actor_info_scene(actor: Actor):
	var instance = MINI_ACTOR_INFO_SCENE.instantiate() as MiniActorInfo
	var actor_visual_manager = actor.get_visual_manager()
	var mini_actor_info_container = actor_visual_manager.get_mini_actor_info_container()

	mini_actor_info_container.get_node("SubViewport").add_child(instance)
	actor_visual_manager.attach_mini_actor_info(instance)
	
	var sprite_3D = mini_actor_info_container.get_node("Sprite3D")
	sprite_3D.reparent(_mini_actor_info_container)

func instantiate_action_order_visual_scene(actor: Actor):
	var instance = ACTION_ORDER_VISUAL_SCENE.instantiate() as ActionOrderVisual
	_action_order_visual_container.add_child(instance)
	instance.attach_actor(actor)
	_blackboard.get_value("action_order_visuals").append(instance)

func choose_act(acting_actor: Actor):
	_blackboard.set_value("acting_actor", acting_actor)
	_blackboard.set_value("act_selected", Signal(act_selected))
	_state_machine.fire_event("select_act")
	
	#var act = await _act_selector.act_selected
	var act = await _blackboard.get_value("act_selected")
	
	return act

func select_targets(act: Act, selectable_target_actors: Array):
	_blackboard.set_value("selectable_target_actors", selectable_target_actors)
	_blackboard.set_value("selecting_target_actors_for_act", act)
	_blackboard.set_value("selected_target_actors", [])
	_blackboard.set_value("target_actors_selected", Signal(targets_selected))
	
	_state_machine.fire_event("select_targets")
	
	var targets = await _blackboard.get_value("target_actors_selected")
	
	return targets

func _process(_delta):
	_update_mini_actor_info_camera()
	_update_hold_circle()

func _update_mini_actor_info_camera():
	_mini_actor_info_camera.global_position = _stage_camera.global_position
	_mini_actor_info_camera.global_rotation = _stage_camera.global_rotation

func _update_hold_circle():
	if _inspect_timer.is_stopped():
		_hold_circle.set_progress(0, 0, 1)
		return
	
	_hold_circle.set_progress(_inspect_timer.wait_time - _inspect_timer.time_left, 0.0, 1.0)

func get_stage() -> StageManager:
	return _stage
func get_stage_camera() -> StageCamera:
	return _stage_camera
func get_ready_camera() -> Camera3D:
	return _ready_camera
func get_attack_camera() -> Camera3D:
	return _attack_camera
func get_defend_camera() -> Camera3D:
	return _defend_camera

func get_mini_actor_viewport_container() -> Control:
	return _mini_actor_viewport_container
func get_main_container() -> Control:
	return _main_container
func get_inspect_interface_container() -> Control:
	return _inspect_interface_container

func get_inspect_timer() -> Timer:
	return _inspect_timer
func get_inspect_delay_timer() -> Timer:
	return _inspect_delay_timer
	
func get_act_selector() -> ActSelector:
	return _act_selector
	
func get_actor_info_container() -> Control:
	return _actor_info_container
func get_mini_actor_info_container() -> Control:
	return _mini_actor_info_container
func get_action_order_visual_container() -> Control:
	return _action_order_visual_container

func get_blackboard() -> BTBlackboard:
	return _blackboard
