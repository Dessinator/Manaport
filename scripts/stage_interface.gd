class_name StageInterface extends CanvasLayer

signal act_selected
# if provided an empty array, will treat the action like
# cancelling target selection.
signal targets_selected(target_actors: Array)

const ACTOR_INFO_SCENE = preload("res://content/stage/actor_info.tscn")
const MINI_ACTOR_INFO_SCENE = preload("res://content/stage/mini_actor_info.tscn")
const ACTION_ORDER_VISUAL_SCENE = preload("res://content/stage/action_order_visual.tscn")

@onready var _stage: StageManager = $".."

@onready var _stage_camera: Camera3D = $"../StageCamera3D"
@onready var _ready_camera: Camera3D = $"../ReadyCamera3D"
@onready var _attack_camera: Camera3D = $"../AttackCamera3D"
@onready var _defend_camera: Camera3D = $"../DefendCamera3D"

@onready var _act_selector: ActSelector = $MarginContainer/ActSelector

@onready var _actor_info_container = $MarginContainer/PartyMembers/Background/HBoxContainer
@onready var _party_action_order_container = $MarginContainer/ActionOrderTimeline/Background/Party
@onready var _enemy_action_order_container = $MarginContainer/ActionOrderTimeline/Background/Enemies

var _action_order_visuals: Array[ActionOrderVisual]

var _selectable_target_actors: Array
# variable used by _select_actors_mode method to communicate with the original select_targets method.
var _selected_actors: Array
# setting _selecting_actors_for_act lets the _select_actors_mode method run depending on
# the act's act_type. setting this to null will disable this.
var _selecting_actors_for_act: Act
var _select_actors_mode = {
	0: _select_single_target,
	1: _select_all_targets,
	2: _select_bell,
	3: _select_bell,
	4: _select_single_target,
	5: _select_all_targets,
	6: _select_single_target,
	7: _select_all_targets,
	8: _select_single_target,
	9: _select_all_targets,
	10: _select_single_target,
	11:_select_all_targets
}

func _ready():
	var cam_tween = get_tree().create_tween()
	cam_tween.set_parallel(true)
	cam_tween.tween_property(_stage_camera, "position", _ready_camera.position, 0.5)
	cam_tween.tween_property(_stage_camera, "rotation", _ready_camera.rotation, 0.5)

func instantiate_actor_info_scene(actor: Actor):
	var instance = ACTOR_INFO_SCENE.instantiate() as ActorInfo
	_actor_info_container.add_child(instance)
	actor.get_visual_manager().attach_actor_info(instance)
func instantiate_mini_actor_info_scene(actor: Actor):
	var instance = MINI_ACTOR_INFO_SCENE.instantiate() as MiniActorInfo
	var actor_visual_manager = actor.get_visual_manager()

	actor_visual_manager.get_mini_actor_info_container().get_node("SubViewport/CanvasLayer").add_child(instance)
	actor_visual_manager.attach_mini_actor_info(instance)

func instantiate_action_order_visual_scene(actor: Actor):
	var instance = ACTION_ORDER_VISUAL_SCENE.instantiate() as ActionOrderVisual
	if actor.is_party_member():
		_party_action_order_container.add_child(instance)
	else:
		_enemy_action_order_container.add_child(instance)
	instance.attach_actor(actor)
	_action_order_visuals.append(instance)

func choose_act(acting_actor: Actor):
	_act_selector.show_acts(acting_actor)
	
	var cam_tween = get_tree().create_tween()
	cam_tween.set_parallel(true)
	cam_tween.tween_property(_stage_camera, "position", _defend_camera.position, 0.5)
	cam_tween.tween_property(_stage_camera, "rotation", _defend_camera.rotation, 0.5)

	return await _act_selector.act_selected

func select_targets(act: Act, selectable_target_actors: Array):
	_selecting_actors_for_act = act
	_selectable_target_actors = selectable_target_actors

	if act.do_friendly_fire():
		var cam_tween = get_tree().create_tween()
		cam_tween.set_parallel(true)
		cam_tween.tween_property(_stage_camera, "position", _defend_camera.position, 0.5)
		cam_tween.tween_property(_stage_camera, "rotation", _defend_camera.rotation, 0.5)	
	else:
		var cam_tween = get_tree().create_tween()
		cam_tween.set_parallel(true)
		cam_tween.tween_property(_stage_camera, "position", _attack_camera.position, 0.5)
		cam_tween.tween_property(_stage_camera, "rotation", _attack_camera.rotation, 0.5)

	var targets = await targets_selected
	_selecting_actors_for_act = null
	_selectable_target_actors = []
	_selected_actors = []

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(_stage_camera, "position", _ready_camera.position, 0.5)
	tween.tween_property(_stage_camera, "rotation", _ready_camera.rotation, 0.5)

	return targets

func _select_single_target():	
	if _selected_actors.size() == 0:
		_selected_actors.append(_selectable_target_actors[0])
		_selected_actors[0].select()
	
	if Input.is_action_just_pressed("ui_right"):
		var current_actor_index = _selectable_target_actors.find(_selected_actors[0])
		var next_actor_index = (current_actor_index + 1) % _selectable_target_actors.size()
		_selected_actors[0].deselect()
		_selected_actors.clear()
		_selected_actors.append(_selectable_target_actors[next_actor_index])
		_selected_actors[0].select()

	if Input.is_action_just_pressed("ui_left"):
		var current_actor_index = _selectable_target_actors.find(_selected_actors[0])
		var next_actor_index = (current_actor_index - 1) % _selectable_target_actors.size()
		_selected_actors[0].deselect()
		_selected_actors.clear()
		_selected_actors.append(_selectable_target_actors[next_actor_index])
		_selected_actors[0].select()
	
	if Input.is_action_just_pressed("ui_accept"):
		_selected_actors[0].deselect()
		targets_selected.emit(_selected_actors)
	
	if Input.is_action_just_pressed("ui_cancel"):
		_selected_actors[0].deselect()
		_selected_actors.clear()
		targets_selected.emit(_selected_actors)
func _select_all_targets():
	for actor in _selectable_target_actors:
		if _selected_actors.has(actor):
			continue
		
		_selected_actors.append(actor)
		actor.select()
	
	if Input.is_action_just_pressed("ui_accept"):
		for actor in _selected_actors:
			actor.deselect()
		targets_selected.emit(_selected_actors)
	
	if Input.is_action_just_pressed("ui_cancel"):
		for actor in _selected_actors:
			actor.deselect()
		_selected_actors.clear()
		targets_selected.emit(_selected_actors)
		
func _select_bell():
	if _selected_actors.size() == 0:
		# get middle index, then the two surrounding indexes if they are valid.
		var middle_index = _selectable_target_actors.size() / 2
		var right_index = middle_index + 1
		var left_index = middle_index - 1

		_selected_actors.append(_selectable_target_actors[middle_index])

		if right_index < _selectable_target_actors.size():
			_selected_actors.append(_selectable_target_actors[right_index])
		if left_index >= 0:
			_selected_actors.append(_selectable_target_actors[left_index])
		
		for actor in _selected_actors:
			actor.select()
	
	if Input.is_action_just_pressed("ui_right"):
		for actor in _selected_actors:
			actor.deselect()
		
		var current_actor_index = _selectable_target_actors.find(_selected_actors[0])
		_selected_actors.clear()
		# new "middle_index"
		var next_actor_index = (current_actor_index + 1) % _selectable_target_actors.size()
		var right_index = next_actor_index + 1
		var left_index = next_actor_index - 1
		
		_selected_actors.append(_selectable_target_actors[next_actor_index])

		if right_index < _selectable_target_actors.size():
			_selected_actors.append(_selectable_target_actors[right_index])
		if left_index >= 0:
			_selected_actors.append(_selectable_target_actors[left_index])

		for actor in _selected_actors:
			actor.select()

	if Input.is_action_just_pressed("ui_left"):
		for actor in _selected_actors:
			actor.deselect()

		var current_actor_index = _selectable_target_actors.find(_selected_actors[0])
		_selected_actors.clear()
		# new "middle_index"
		var next_actor_index = current_actor_index - 1
		if next_actor_index < 0:
			next_actor_index = _selectable_target_actors.size() - 1
		var right_index = next_actor_index + 1
		var left_index = next_actor_index - 1

		_selected_actors.append(_selectable_target_actors[next_actor_index])

		if right_index < _selectable_target_actors.size():
			_selected_actors.append(_selectable_target_actors[right_index])
		if left_index >= 0:
			_selected_actors.append(_selectable_target_actors[left_index])

		for actor in _selected_actors:
			actor.select()
	
	if Input.is_action_just_pressed("ui_accept"):
		for actor in _selected_actors:
			actor.deselect()
		targets_selected.emit(_selected_actors)
	
	if Input.is_action_just_pressed("ui_cancel"):
		for actor in _selected_actors:
			actor.deselect()
		_selected_actors.clear()
		targets_selected.emit(_selected_actors)

func _process(delta):
	if _selecting_actors_for_act:
		_select_actors_mode[_selecting_actors_for_act.get_act_type()].call()

	_update_action_order_visuals(delta)

func _update_action_order_visuals(delta):
	var visuals_to_remove = []

	for visual in _action_order_visuals:
		var non_dead_attached_actors = visual.get_attached_actors().filter(func(a): return not a.get_status().is_dead())

		# if there is a dead actor attached to this visual, remove it and reduce the count
		visual.set_attached_actors(non_dead_attached_actors)

		# all actors dead, remove this visual
		if non_dead_attached_actors.size() == 0:
			visuals_to_remove.append(visual)

			# no need to update this visual if all actors are dead.
			continue

		

		# get the first actor in the attached actors list
		var actor = non_dead_attached_actors[0]

		# # if the first actor has risen already, remove the actor from this visual's
		# # attached actors list and make a new visual at the start of the action order
		# # timeline
		# if actor.has_acted():
		# 	non_dead_attached_actors.erase(actor)
		# 	visual.set_attached_actors(non_dead_attached_actors)

		# 	instantiate_action_order_visual_scene(actor)

		var x = remap(actor.get_readiness(), 0, actor.MAX_READINESS, 0, _party_action_order_container.size.x)
		var target_position = Vector2(x, 0)

		visual.position = target_position
	
	for visual in visuals_to_remove:
		_action_order_visuals.erase(visual)
		visual.queue_free()

func get_stage() -> StageManager:
	return _stage
