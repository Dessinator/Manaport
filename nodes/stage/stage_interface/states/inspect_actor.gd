@tool
extends FSMState

# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as StageInterface
	
	var inspect_interface = actor.get_inspect_interface()
	
	actor.remove_child(actor.get_main_container())
	actor.remove_child(actor.get_mini_actor_viewport_container())
	actor.add_child(inspect_interface)

	inspect_interface.next_actor.connect(_on_inspect_interface_next_actor.bind(actor, blackboard))
	inspect_interface.previous_actor.connect(_on_inspect_interface_previous_actor.bind(actor, blackboard))

	set_inspected_actor(blackboard.get_value("actor_to_inspect"), actor)

# Executes every _process call, if the state is active.
func _on_update(_delta: float, actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as StageInterface
	
	if Input.is_action_just_pressed("right"):
		inspect_next_actor(actor, blackboard)
	if Input.is_action_just_pressed("left"):
		inspect_prev_actor(actor, blackboard)
	
	if Input.is_action_just_pressed("cancel"):
		var return_event = String(str(blackboard.get_value("return_event")))
		blackboard.remove_value("return_event")
		get_parent().fire_event(return_event)

func _on_inspect_interface_next_actor(stage_interface: StageInterface, blackboard: BTBlackboard):
	inspect_next_actor(stage_interface, blackboard)
func _on_inspect_interface_previous_actor(stage_interface: StageInterface, blackboard: BTBlackboard):
	inspect_prev_actor(stage_interface, blackboard)

func inspect_next_actor(stage_interface: StageInterface, blackboard: BTBlackboard):
	var inspectable_actors = blackboard.get_value("actors")
	var current_inspected_actor = blackboard.get_value("actor_to_inspect")
	
	var current_actor_index = inspectable_actors.find(current_inspected_actor)
	var next_actor_index = (current_actor_index + 1) % inspectable_actors.size()
	blackboard.set_value("actor_to_inspect", inspectable_actors[next_actor_index])
	set_inspected_actor(blackboard.get_value("actor_to_inspect"), stage_interface)
func inspect_prev_actor(stage_interface: StageInterface, blackboard: BTBlackboard):
	var inspectable_actors = blackboard.get_value("actors")
	var current_inspected_actor = blackboard.get_value("actor_to_inspect")
	
	var current_actor_index = inspectable_actors.find(current_inspected_actor)
	var next_actor_index = (current_actor_index - 1) % inspectable_actors.size()
	blackboard.set_value("actor_to_inspect", inspectable_actors[next_actor_index])
	set_inspected_actor(blackboard.get_value("actor_to_inspect"), stage_interface)

func set_inspected_actor(actor: Actor, stage_interface: StageInterface):
	var stage_camera = stage_interface.get_stage_camera()
	
	var actor_inspect_camera = actor.get_node("InspectCamera")
	
	var cam_tween = get_tree().create_tween()
	cam_tween.set_parallel(true)
	cam_tween.tween_property(stage_camera, "position", actor_inspect_camera.global_position, 0.5)
	cam_tween.tween_property(stage_camera, "rotation", actor_inspect_camera.global_rotation, 0.5)
	
	stage_interface.get_inspect_interface().inspect(actor)

# Executes before the state is exited.
func _on_exit(actor: Node, _blackboard: BTBlackboard) -> void:
	actor = actor as StageInterface
	
	var inspect_interface = actor.get_inspect_interface()
	
	inspect_interface.next_actor.disconnect(_on_inspect_interface_next_actor)
	inspect_interface.previous_actor.disconnect(_on_inspect_interface_previous_actor)
	
	actor.add_child(actor.get_main_container())
	actor.add_child(actor.get_mini_actor_viewport_container())
	actor.remove_child(actor.get_inspect_interface())

# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings
