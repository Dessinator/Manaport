class_name ActSelector extends Control

signal act_selected(act: Act)

const ACT_BUTTON_SCENE = preload("res://nodes/stage/act_button.tscn")

@onready var _stage_interface: StageInterface = $"../.."

@onready var _act_button_container = $Background/VBoxContainer

@onready var _basic_move_button: ActButton = $Background/VBoxContainer/BasicMove
@onready var _skill_button: ActButton = $Background/VBoxContainer/Skill
@onready var _use_item_button: ActButton = $Background/VBoxContainer/UseItem
@onready var _escape_button: ActButton = $Background/VBoxContainer/Escape

enum SelectionState { HIDDEN, MAIN, BASIC_ATTACK, SKILL, ITEM, ESCAPE }
var _selection_state: SelectionState = SelectionState.HIDDEN

var _call_show_actor_basic_attack: Callable
var _call_show_actor_skills: Callable
var _call_show_stage_items: Callable

func _ready():
	close_acts()

func show_acts(acting_actor: Actor):
	_selection_state = SelectionState.MAIN
	_add_main_act_buttons()

	_call_show_actor_basic_attack = func():
		_show_actor_basic_attack(acting_actor)
	_call_show_actor_skills = func():
		_show_actor_skills(acting_actor)
	_call_show_stage_items = func():
		_show_stage_items()

	_basic_move_button.get_button().pressed.connect(_call_show_actor_basic_attack)
	_skill_button.get_button().pressed.connect(_call_show_actor_skills)
	_use_item_button.get_button().pressed.connect(_call_show_stage_items)

func close_acts():
	_selection_state = SelectionState.HIDDEN
	_remove_main_act_buttons()

	if _call_show_actor_basic_attack: _basic_move_button.get_button().pressed.disconnect(_call_show_actor_basic_attack)
	if _call_show_actor_skills: _skill_button.get_button().pressed.disconnect(_call_show_actor_skills)
	if _call_show_stage_items: _use_item_button.get_button().pressed.disconnect(_call_show_stage_items)

	_call_show_actor_basic_attack = func(): pass
	_call_show_actor_skills = func(): pass
	_call_show_stage_items = func(): pass

func _show_actor_basic_attack(acting_actor: Actor):
	_selection_state = SelectionState.BASIC_ATTACK
	_remove_main_act_buttons()

	var button_instance: ActButton = ACT_BUTTON_SCENE.instantiate() as ActButton
	_act_button_container.add_child(button_instance)
	var act_instance: Act = acting_actor.get_acts_manager().get_basic_move_instance()

	button_instance.set_button_text(act_instance.get_act_name())
	button_instance.set_info_visible(true)
	button_instance.set_element(act_instance.get_act_element())
	button_instance.set_act_type(act_instance.get_act_type())
	button_instance.set_stamina_modifier(act_instance.does_recover_stamina(), act_instance.get_stamina_modifier())

	button_instance.update_info_text()

	button_instance.get_button().pressed.connect(func():
			button_instance.queue_free()
			act_selected.emit(act_instance)
			close_acts()
			)
func _show_actor_skills(acting_actor: Actor):
	_selection_state = SelectionState.SKILL
	_remove_main_act_buttons()

	var acts_manager = acting_actor.get_acts_manager()
	for skill in [acts_manager.get_skill_1_instance(), acts_manager.get_skill_2_instance()]:
		var button_instance: ActButton = ACT_BUTTON_SCENE.instantiate() as ActButton
		_act_button_container.add_child(button_instance)

		button_instance.set_button_text(skill.get_act_name())
		button_instance.set_info_visible(true)
		button_instance.set_element(skill.get_act_element())
		button_instance.set_act_type(skill.get_act_type())
		button_instance.set_stamina_modifier(skill.does_recover_stamina(), skill.get_stamina_modifier())

		button_instance.update_info_text()

		if acting_actor.get_status().get_stamina() - skill.get_stamina_modifier() < 0:
			button_instance.set_unavailable()
			continue

		button_instance.get_button().pressed.connect(func():
				for button in _act_button_container.get_children():
					button.queue_free()
				act_selected.emit(skill)
				close_acts()
				)
func _show_stage_items():
	_selection_state = SelectionState.ITEM
	_remove_main_act_buttons()

	var stage = _stage_interface.get_stage()

	var acts = stage.get_stage_acts_manager().get_all_act_instances()
	for act in acts:
		var button_instance: ActButton = ACT_BUTTON_SCENE.instantiate() as ActButton
		_act_button_container.add_child(button_instance)

		button_instance.set_button_text(act.get_act_name())
		button_instance.set_info_visible(false)
		button_instance.set_act_type(act.get_act_type())

		if act.is_locked():
			button_instance.set_unavailable()

		button_instance.update_info_text()

		button_instance.get_button().pressed.connect(func():
			for button in _act_button_container.get_children():
				button.queue_free()
			act_selected.emit(act)
			close_acts()
		)

func _process(_delta):

	# when pressing esc, go back to the main selection state
	if Input.is_action_just_pressed("ui_cancel"):
		if _selection_state == SelectionState.BASIC_ATTACK:
			var button_instance = _act_button_container.get_child(0)
			button_instance.queue_free()
			close_acts()
			act_selected.emit(null)
		if _selection_state == SelectionState.SKILL:
			for button in _act_button_container.get_children():
				button.queue_free()
			close_acts()
			act_selected.emit(null)


func _add_main_act_buttons():
	_act_button_container.add_child(_basic_move_button)
	_act_button_container.add_child(_skill_button)
	_act_button_container.add_child(_use_item_button)
	_act_button_container.add_child(_escape_button)

func _remove_main_act_buttons():
	if _basic_move_button.is_inside_tree(): _act_button_container.remove_child(_basic_move_button)
	if _skill_button.is_inside_tree(): _act_button_container.remove_child(_skill_button)
	if _use_item_button.is_inside_tree(): _act_button_container.remove_child(_use_item_button)
	if _escape_button.is_inside_tree(): _act_button_container.remove_child(_escape_button)
