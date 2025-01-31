@tool
extends FSMState

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as StageInterface
	
	var act_selector = actor.get_act_selector()
	
	act_selector.show_acts(blackboard.get_value("acting_actor"))
	
	var stage_camera = actor.get_stage_camera()
	stage_camera.start_hold.connect(_on_start_hold.bind(actor, blackboard))
	stage_camera.hold.connect(_on_hold.bind(actor, blackboard))
	stage_camera.end_hold.connect(_on_end_hold.bind(actor, blackboard))
	actor.get_inspect_timer().timeout.connect(_on_inspect_timer_timeout.bind(blackboard))
	
	var cam_tween = get_tree().create_tween()
	cam_tween.set_parallel(true)
	cam_tween.tween_property(stage_camera, "position", actor.get_defend_camera().position, 0.5)
	cam_tween.tween_property(stage_camera, "rotation", actor.get_defend_camera().rotation, 0.5)
	
	act_selector.get_blackboard().get_value("act_selected").connect(_on_act_selected.bind(blackboard.get_value("act_selected")))

func _on_act_selected(act: Act, act_selected_signal: Signal):
	act_selected_signal.emit(act)

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as StageInterface
	var stage_camera = actor.get_stage_camera()
	
	stage_camera.start_hold.disconnect(_on_start_hold)
	stage_camera.hold.disconnect(_on_hold)
	stage_camera.end_hold.disconnect(_on_end_hold)
	
	actor.get_inspect_timer().stop()
	actor.get_inspect_delay_timer().stop()
	actor.get_inspect_timer().timeout.disconnect(_on_inspect_timer_timeout)
	actor.get_inspect_delay_timer().timeout.disconnect(_on_inspect_delay_timer_timeout)
	
	actor.get_act_selector().get_blackboard().get_value("act_selected").disconnect(_on_act_selected)

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
	
	if not inspect_delay_timer.timeout.is_connected(_on_inspect_delay_timer_timeout):
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
func _on_inspect_timer_timeout(blackboard: BTBlackboard):
	blackboard.set_value("return_event", "return_to_act_selection")
	get_parent().fire_event("inspect_actor")

# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings
