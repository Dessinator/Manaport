@tool
extends FSMState

var SELECT_TARGETS_MODE = {
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

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as StageInterface
	
	var stage_camera = actor.get_stage_camera()
	
	stage_camera.single_click.connect(_on_single_click.bind(blackboard))
	stage_camera.double_click.connect(_on_double_click.bind(blackboard))
	stage_camera.start_hold.connect(_on_start_hold.bind(actor, blackboard))
	stage_camera.hold.connect(_on_hold.bind(actor, blackboard))
	stage_camera.end_hold.connect(_on_end_hold.bind(actor, blackboard))
	actor.get_inspect_timer().timeout.connect(_on_inspect_timer_timeout)
	
	var selecting_target_actors_for_act = blackboard.get_value("selecting_target_actors_for_act")
	
	var defend_camera = actor.get_defend_camera()
	var attack_camera = actor.get_attack_camera()

	if selecting_target_actors_for_act.do_friendly_fire():
		var cam_tween = get_tree().create_tween()
		cam_tween.set_parallel(true)
		cam_tween.tween_property(stage_camera, "position", defend_camera.position, 0.5)
		cam_tween.tween_property(stage_camera, "rotation", defend_camera.rotation, 0.5)	
	else:
		var cam_tween = get_tree().create_tween()
		cam_tween.set_parallel(true)
		cam_tween.tween_property(stage_camera, "position", attack_camera.position, 0.5)
		cam_tween.tween_property(stage_camera, "rotation", attack_camera.rotation, 0.5)
	
	SELECT_TARGETS_MODE[selecting_target_actors_for_act.get_act_type()].call(blackboard.get_value("selectable_target_actors")[0], blackboard)

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, blackboard: BTBlackboard) -> void:
	var selectable_target_actors = blackboard.get_value("selectable_target_actors")
	var selected_target_actors = blackboard.get_value("selected_target_actors")
	var selecting_target_actors_for_act = blackboard.get_value("selecting_target_actors_for_act")
	var selecting_target_actors_for_act_type = selecting_target_actors_for_act.get_act_type()
	
	if Input.is_action_just_pressed("confirm"):
		_confirm_selection(selected_target_actors, blackboard.get_value("target_actors_selected"))
	
	if Input.is_action_just_pressed("cancel"):
		for actor in selected_target_actors:
			actor.deselect()
		selected_target_actors.clear()
		_confirm_selection(selected_target_actors, blackboard.get_value("target_actors_selected"))
	
	if selecting_target_actors_for_act_type == Act.Type.MULTI_TARGET:
		return
	
	if Input.is_action_just_pressed("right"):
		var current_actor_index = selectable_target_actors.find(selected_target_actors[0])
		var next_actor_index = (current_actor_index + 1) % selectable_target_actors.size()
		SELECT_TARGETS_MODE[selecting_target_actors_for_act_type].call(selectable_target_actors[next_actor_index], blackboard)

	if Input.is_action_just_pressed("left"):
		var current_actor_index = selectable_target_actors.find(selected_target_actors[0])
		var next_actor_index = (current_actor_index - 1) % selectable_target_actors.size()
		SELECT_TARGETS_MODE[selecting_target_actors_for_act_type].call(selectable_target_actors[next_actor_index], blackboard)

func _on_single_click(result: Dictionary, blackboard: BTBlackboard):
	if result.is_empty():
		return
	
	var collider = result["collider"]
	var actor = collider.get_node("../..")
	
	if not actor:
		return
	
	SELECT_TARGETS_MODE[blackboard.get_value("selecting_target_actors_for_act").get_act_type()].call(actor, blackboard)
func _on_double_click(result: Dictionary, blackboard: BTBlackboard):
	if result.is_empty():
		return
	
	var collider = result["collider"]
	var actor = collider.get_node("../..")
	
	if not actor:
		return
	
	if not blackboard.get_value("selectable_target_actors").has(actor):
		return
	
	_confirm_selection(blackboard.get_value("selected_target_actors"), blackboard.get_value("target_actors_selected"))

func _select_single_target(center_actor: Actor, blackboard: BTBlackboard):
	var selectable_target_actors = blackboard.get_value("selectable_target_actors")
	var selected_target_actors = blackboard.get_value("selected_target_actors")
	
	if not selectable_target_actors.has(center_actor):
		return
	
	if not selected_target_actors.is_empty():
		selected_target_actors[0].deselect()
		selected_target_actors.clear()
	selected_target_actors.append(center_actor)
	selected_target_actors[0].select()
func _select_all_targets(_center_actor: Actor, blackboard: BTBlackboard):
	var selectable_target_actors = blackboard.get_value("selectable_target_actors")
	var selected_target_actors = blackboard.get_value("selected_target_actors")
	
	for actor in selectable_target_actors:
		if selected_target_actors.has(actor):
			continue
		
		selected_target_actors.append(actor)
		actor.select()
func _select_bell(center_actor: Actor, blackboard: BTBlackboard):
	var selectable_target_actors = blackboard.get_value("selectable_target_actors")
	var selected_target_actors = blackboard.get_value("selected_target_actors")
	
	if not selectable_target_actors.has(center_actor):
		return
	
	if not selected_target_actors.is_empty():
		for actor in selected_target_actors:
			actor.deselect()
		selected_target_actors.clear()
	
	var center_actor_index = selectable_target_actors.find(center_actor)
	
	var right_index = center_actor_index + 1
	var left_index = center_actor_index - 1
	
	selected_target_actors.append(selectable_target_actors[center_actor_index])

	if right_index < selectable_target_actors.size():
		selected_target_actors.append(selectable_target_actors[right_index])
	if left_index >= 0:
		selected_target_actors.append(selectable_target_actors[left_index])

	for actor in selected_target_actors:
		actor.select()

func _confirm_selection(selected_target_actors: Array, targets_selected_signal: Signal):
	if selected_target_actors.is_empty():
		get_parent().fire_event("cancel_target_selection")
	else:
		for actor in selected_target_actors:
			actor.deselect()
		get_parent().fire_event("confirm_target_selection")
	targets_selected_signal.emit(selected_target_actors)

func _on_start_hold(result: Dictionary, actor: Node, blackboard: BTBlackboard):
	if result.is_empty():
		return
	
	var collider = result["collider"]
	var clicked_actor = collider.get_node("../..")
	
	if not clicked_actor:
		return
	
	blackboard.set_value("actor_to_inspect", clicked_actor)
	
	var inspect_delay_timer = actor.get_inspect_delay_timer()
	if inspect_delay_timer.is_stopped():
		inspect_delay_timer.start()
func _on_hold(result: Dictionary, actor: Node, blackboard: BTBlackboard):
	var inspect_delay_timer = actor.get_inspect_delay_timer()
	var inspect_timer = actor.get_inspect_timer()
	
	if result.is_empty():
		blackboard.remove_value("actor_to_inspect")
		inspect_timer.stop()
		return
	
	var collider = result["collider"]
	var clicked_actor = collider.get_node("../..")
	
	if not clicked_actor:
		blackboard.remove_value("actor_to_inspect")
		inspect_timer.stop()
		return
	
	inspect_delay_timer.timeout.connect(_on_inspect_delay_timer_timeout.bind(inspect_timer, blackboard.get_value("actor_to_inspect")))
func _on_end_hold(result: Dictionary, actor: Node, blackboard: BTBlackboard):
	blackboard.remove_value("actor_to_inspect")
	actor.get_inspect_timer().stop()
	actor.get_inspect_delay_timer().timeout.disconnect(_on_inspect_delay_timer_timeout)
	
	#if result.is_empty():
		#_actor_to_inspect = null
		#_inspect_timer.stop()
		#return
	#
	#var collider = result["collider"]
	#var clicked_actor = collider.get_node("../..")
	#
	#if not clicked_actor:
		#_actor_to_inspect = null
		#_inspect_timer.stop()
		#return
	#_actor_to_inspect = null
	#_inspect_timer.stop()

func _on_inspect_delay_timer_timeout(inspect_timer: Timer, actor_to_inspect: Actor):
	if inspect_timer.is_stopped() and actor_to_inspect:
		inspect_timer.start()
func _on_inspect_timer_timeout():
	get_parent().fire_event("inspect_actor")

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as StageInterface
	
	blackboard.remove_value("selecting_target_actors_for_act")
	blackboard.remove_value("selectable_target_actors")
	blackboard.remove_value("selected_target_actors")
	
	var stage_camera = actor.get_stage_camera()
	var ready_camera = actor.get_ready_camera()
	
	stage_camera.single_click.disconnect(_on_single_click)
	stage_camera.double_click.disconnect(_on_double_click)
	stage_camera.start_hold.disconnect(_on_start_hold)
	stage_camera.hold.disconnect(_on_hold)
	stage_camera.end_hold.disconnect(_on_end_hold)
	
	blackboard.remove_value("actor_to_inspect")
	actor.get_inspect_timer().stop()
	actor.get_inspect_delay_timer().stop()
	actor.get_inspect_timer().timeout.disconnect(_on_inspect_timer_timeout)
	actor.get_inspect_delay_timer().timeout.disconnect(_on_inspect_delay_timer_timeout)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(stage_camera, "position", ready_camera.position, 0.5)
	tween.tween_property(stage_camera, "rotation", ready_camera.rotation, 0.5)

# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings
