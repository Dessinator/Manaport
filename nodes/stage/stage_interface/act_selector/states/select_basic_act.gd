@tool
extends FSMState


# Executes after the state is entered.
func _on_enter(actor: Node, blackboard: BTBlackboard) -> void:
	actor = actor as ActSelector
	
	_remove_main_act_buttons(blackboard)
	
	var button_instance: ActButton = actor.ACT_BUTTON_SCENE.instantiate() as ActButton
	blackboard.get_value("act_button_container").add_child(button_instance)
	var act_instance: Act = blackboard.get_value("acting_actor").get_acts_manager().get_basic_move_instance()

	button_instance.set_button_text(act_instance.get_act_name())
	button_instance.set_info_visible(true)
	button_instance.set_element(act_instance.get_act_element())
	button_instance.set_act_type(act_instance.get_act_type())
	button_instance.set_stamina_modifier(act_instance.does_recover_stamina(), act_instance.get_stamina_modifier())

	button_instance.update_info_text()

	button_instance.get_button().pressed.connect(func():
			button_instance.queue_free()
			blackboard.get_value("act_selected").emit(act_instance)
			get_parent().fire_event("confirm_selection")
			)

func _remove_main_act_buttons(blackboard: BTBlackboard):
	var container = blackboard.get_value("act_button_container")
	
	container.remove_child(blackboard.get_value("basic_move_button"))
	container.remove_child(blackboard.get_value("skill_button"))
	container.remove_child(blackboard.get_value("item_button"))
	container.remove_child(blackboard.get_value("escape_button"))

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	if Input.is_action_just_pressed("cancel"):
		get_parent().fire_event("cancel_selection")


# Executes before the state is exited.
func _on_exit(_actor: Node, blackboard: BTBlackboard) -> void:
	for button in blackboard.get_value("act_button_container").get_children():
		button.queue_free()


# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings
