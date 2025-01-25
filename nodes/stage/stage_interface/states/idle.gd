@tool
extends FSMState


# Executes after the state is entered.
func _on_enter(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as StageInterface
	
	var stage_camera = actor.get_stage_camera()
	var ready_camera = actor.get_ready_camera()
	
	var cam_tween = get_tree().create_tween()
	cam_tween.set_parallel(true)
	cam_tween.tween_property(stage_camera, "position", ready_camera.position, 0.5)
	cam_tween.tween_property(stage_camera, "rotation", ready_camera.rotation, 0.5)
	
	actor.remove_child(actor.get_inspect_interface_container())

# Executes every _process call, if the state is active.
func _on_update(_delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	_update_action_order_visuals(actor, blackboard.get_value("action_order_visuals"))

func _update_action_order_visuals(actor: Node, action_order_visuals: Array):
	var visuals_to_remove = []

	for visual in action_order_visuals:
		var non_dead_attached_actors = visual.get_attached_actors().filter(func(a): return not a.get_status().is_dead())

		# if there is a dead actor attached to this visual, remove it and reduce the count
		visual.set_attached_actors(non_dead_attached_actors)

		# all actors dead, remove this visual
		if non_dead_attached_actors.size() == 0:
			visuals_to_remove.append(visual)
			# no need to update this visual if all actors are dead.
			continue

		# get the first actor in the attached actors list
		var attached_actor = non_dead_attached_actors[0]

		var x = remap(attached_actor.get_readiness(), 0, attached_actor.MAX_READINESS, 0, actor.get_action_order_visual_container().size.x)
		var target_position = Vector2(x, 0)

		visual.position = target_position
	
	for visual in visuals_to_remove:
		action_order_visuals.erase(visual)
		visual.queue_free()

# Executes before the state is exited.
func _on_exit(_actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings
