@tool
extends FSMState


# Executes after the state is entered.
func _on_enter(_actor: Node, blackboard: BTBlackboard) -> void:
	#func _remove_main_act_buttons(blackboard: BTBlackboard):
	var container = blackboard.get_value("act_button_container")
	
	container.remove_child(blackboard.get_value("basic_move_button"))
	container.remove_child(blackboard.get_value("skill_button"))
	container.remove_child(blackboard.get_value("item_button"))
	container.remove_child(blackboard.get_value("escape_button"))

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass


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
