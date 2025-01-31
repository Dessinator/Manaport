extends PanelContainer

const STATUS_EFFECT_PANEL_SECTION_SCENE = preload("res://nodes/stage/stage_interface/inspect_interface/status_effect_panel/status_effect_panel_section.tscn")

@onready var _status_effect_panel_section_container: VBoxContainer = %StatusEffectPanelSectionContainer

func clear():
	for child in _status_effect_panel_section_container.get_children():
		child.queue_free()

func add_status_effect(status_effect: Dictionary):
	var status_effect_panel_section_instance = STATUS_EFFECT_PANEL_SECTION_SCENE.instantiate()
	_status_effect_panel_section_container.add_child(status_effect_panel_section_instance)
	
	status_effect_panel_section_instance.set_status_effect_icon(status_effect["metadata"]["icon"])
	status_effect_panel_section_instance.set_status_effect_name(status_effect["metadata"]["name"])
	
	status_effect_panel_section_instance.set_status_effect_stacks(status_effect["stacks"].size())
	status_effect_panel_section_instance.set_status_effect_duration(StatusEffect.get_turns_left_for_status_effect_instance(status_effect))
	
	status_effect_panel_section_instance.set_status_effect_description(status_effect["metadata"]["long_description"])
