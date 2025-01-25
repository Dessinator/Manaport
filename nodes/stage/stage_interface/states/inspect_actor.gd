@tool
extends FSMState

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as StageInterface
	
	var stage_camera = actor.get_stage_camera()
	var actor_to_inspect = blackboard.get_value("actor_to_inspect")
	
	print(actor_to_inspect)
	
	var actor_inspect_camera = actor_to_inspect.get_node("InspectCamera")
	
	var cam_tween = get_tree().create_tween()
	cam_tween.set_parallel(true)
	cam_tween.tween_property(stage_camera, "position", actor_inspect_camera.global_position, 0.5)
	cam_tween.tween_property(stage_camera, "rotation", actor_inspect_camera.global_rotation, 0.5)
	
	actor.remove_child(actor.get_main_container())
	actor.remove_child(actor.get_mini_actor_viewport_container())
	actor.add_child(actor.get_inspect_interface_container())

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass

# Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as StageInterface
	
	actor.add_child(actor.get_main_container())
	actor.add_child(actor.get_mini_actor_viewport_container())
	actor.remove_child(actor.get_inspect_interface_container())

# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings
