@tool
extends FSMState


# Executes after the state is entered.
func _on_enter(_actor: Node, blackboard: BTBlackboard) -> void:
	_add_main_act_buttons(blackboard)

	blackboard.get_value("basic_move_button").get_button().pressed.connect(_select_basic_act)
	blackboard.get_value("skill_button").get_button().pressed.connect(_select_skill)
	blackboard.get_value("item_button").get_button().pressed.connect(_select_item)

func _add_main_act_buttons(blackboard: BTBlackboard):
	var container = blackboard.get_value("act_button_container")
	
	container.add_child(blackboard.get_value("basic_move_button"))
	container.add_child(blackboard.get_value("skill_button"))
	container.add_child(blackboard.get_value("item_button"))
	container.add_child(blackboard.get_value("escape_button"))

func _select_basic_act():
	get_parent().fire_event("select_basic_act")
func _select_skill():
	get_parent().fire_event("select_skill")
func _select_item():
	get_parent().fire_event("select_item")

# Executes every _process call, if the state is active.
func _on_update(_delta: float, _actor: Node, _blackboard: BTBlackboard) -> void:
	pass


# Executes before the state is exited.
func _on_exit(_actor: Node, blackboard: BTBlackboard) -> void:
	blackboard.get_value("basic_move_button").get_button().pressed.disconnect(_select_basic_act)
	blackboard.get_value("skill_button").get_button().pressed.disconnect(_select_skill)
	blackboard.get_value("item_button").get_button().pressed.disconnect(_select_item)

# Add custom configuration warnings
# Note: Can be deleted if you don't want to define your own warnings.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array = []

	warnings.append_array(super._get_configuration_warnings())

	# Add your own warnings to the array here

	return warnings
