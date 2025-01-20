class_name StageInterface extends Control

signal act_selected
# if provided an empty array, will treat the action like
# cancelling target selection.
signal targets_selected(target_actors: Array)

const ACTOR_INFO_SCENE = preload("res://nodes/stage/stage_interface/actor_info/actor_info_card/actor_info_card.tscn")
const MINI_ACTOR_INFO_SCENE = preload("res://nodes/stage/stage_interface/actor_info/mini_actor_info/mini_actor_info.tscn")
const ACTION_ORDER_VISUAL_SCENE = preload("res://nodes/stage/stage_interface/action_order_visual/action_order_visual.tscn")

var SELECT_ACTORS_MODE = {
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
var SELECT_ACTORS_CLICK_MODE = {
	0: _select_single_target_click,
	1: _select_all_targets_click,
	2: _select_bell_click,
	3: _select_bell_click,
	4: _select_single_target_click,
	5: _select_all_targets_click,
	6: _select_single_target_click,
	7: _select_all_targets_click,
	8: _select_single_target_click,
	9: _select_all_targets_click,
	10: _select_single_target_click,
	11:_select_all_targets_click
}

@onready var _stage: StageManager = $".."

@export var _stage_camera: Camera3D
@export var _ready_camera: Camera3D
@export var _attack_camera: Camera3D
@export var _defend_camera: Camera3D

@onready var _mini_actor_info_camera: Camera3D = %MiniActorInfoCamera

@onready var _act_selector: ActSelector = %ActSelector

@onready var _actor_info_container = %ActorInfoCardContainer
@onready var _mini_actor_info_container = %MiniActorInfoContainer
@onready var _action_order_visual_container = %ActionOrderVisualContainer

var _action_order_visuals: Array[ActionOrderVisual]

var _selectable_target_actors: Array
# variable used by _select_actors_mode method to communicate with the original select_targets method.
var _selected_actors: Array
# setting _selecting_actors_for_act lets the _select_actors_mode method run depending on
# the act's act_type. setting this to null will disable this.
var _selecting_actors_for_act: Act

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
	var mini_actor_info_container = actor_visual_manager.get_mini_actor_info_container()

	mini_actor_info_container.get_node("SubViewport").add_child(instance)
	actor_visual_manager.attach_mini_actor_info(instance)
	
	var sprite_3D = mini_actor_info_container.get_node("Sprite3D")
	sprite_3D.reparent(_mini_actor_info_container)
	
	#mini_actor_info_container.reparent(_mini_actor_info_container)

func instantiate_action_order_visual_scene(actor: Actor):
	var instance = ACTION_ORDER_VISUAL_SCENE.instantiate() as ActionOrderVisual
	_action_order_visual_container.add_child(instance)
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
	_selectable_target_actors = selectable_target_actors
	_selecting_actors_for_act = act
	
	_stage_camera.single_click.connect(_on_single_click)
	_stage_camera.double_click.connect(_on_double_click)

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
	_stage_camera.single_click.disconnect(_on_single_click)
	_stage_camera.double_click.disconnect(_on_double_click)

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
func _select_single_target_click(clicked_actor: Actor):
	if not _selectable_target_actors.has(clicked_actor):
		return
	
	_selected_actors[0].deselect()
	_selected_actors.clear()
	_selected_actors.append(clicked_actor)
	_selected_actors[0].select()

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
func _select_all_targets_click(clicked_actor: Actor):
	for actor in _selectable_target_actors:
		if _selected_actors.has(actor):
			continue
		
		_selected_actors.append(actor)
		actor.select()

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
func _select_bell_click(clicked_actor: Actor):
	if not _selectable_target_actors.has(clicked_actor):
		return
	
	for actor in _selected_actors:
		actor.deselect()
	
	var clicked_actor_index = _selectable_target_actors.find(clicked_actor)
	_selected_actors.clear()
	
	var right_index = clicked_actor_index + 1
	var left_index = clicked_actor_index - 1
	
	_selected_actors.append(_selectable_target_actors[clicked_actor_index])

	if right_index < _selectable_target_actors.size():
		_selected_actors.append(_selectable_target_actors[right_index])
	if left_index >= 0:
		_selected_actors.append(_selectable_target_actors[left_index])

	for actor in _selected_actors:
		actor.select()

func _on_single_click(result: Dictionary):
	if result.is_empty():
		return
	
	var collider = result["collider"]
	var actor = collider.get_node("../..")
	
	if not actor:
		return
	
	SELECT_ACTORS_CLICK_MODE[_selecting_actors_for_act.get_act_type()].call(actor)
func _on_double_click(result: Dictionary):
	if result.is_empty():
		return
	
	var collider = result["collider"]
	var actor = collider.get_node("../..")
	
	if not actor:
		return
	
	if not _selectable_target_actors.has(actor):
		return
	
	for a in _selected_actors:
			a.deselect()
	targets_selected.emit(_selected_actors)

func _process(delta):
	if _selecting_actors_for_act:
		SELECT_ACTORS_MODE[_selecting_actors_for_act.get_act_type()].call()

	_update_action_order_visuals(delta)
	_update_mini_actor_info_camera()

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

		var x = remap(actor.get_readiness(), 0, actor.MAX_READINESS, 0, _action_order_visual_container.size.x)
		var target_position = Vector2(x, 0)

		visual.position = target_position
	
	for visual in visuals_to_remove:
		_action_order_visuals.erase(visual)
		visual.queue_free()

func _update_mini_actor_info_camera():
	_mini_actor_info_camera.global_position = _stage_camera.global_position
	_mini_actor_info_camera.global_rotation = _stage_camera.global_rotation

func get_stage() -> StageManager:
	return _stage
