class_name InspectInterface extends Control

const CONTENT_PANEL_SCENE = preload("res://nodes/stage/stage_interface/inspect_interface/content_panel/content_panel.tscn")
const STATUS_EFFECT_PANEL = preload("res://nodes/stage/stage_interface/inspect_interface/status_effect_panel/status_effect_panel.tscn")

signal next_actor
signal previous_actor

@onready var _actor_name_label: Label = %ActorNameLabel
@onready var _actor_level_label: Label = %ActorLevelLabel
@onready var _details_content_panel_container: VBoxContainer = %DetailsContentPanelContainer
@onready var _abilities_content_panel_container: VBoxContainer = %AbilitiesContentPanelContainer
@onready var _status_effect_panel_container: MarginContainer = %StatusEffectPanelContainer

@onready var _status_bar_panel: StatusBarPanel = %StatusBarPanel

var _inspecting_actor: Actor

func inspect(actor: Actor):
	_inspecting_actor = actor
	
	print("inspecting actor: " + _inspecting_actor.name)
	
	var actor_metadata = _inspecting_actor.get_metadata()
	_set_actor_name_label_text(actor_metadata.get_actor_name())
	_set_actor_level_label_text(str(actor_metadata.get_actor_level()))
	
	_clear_container_children()
	_add_content_panel(_details_content_panel_container, "Description", actor_metadata.get_actor_description())
	
	_add_act_content_panels(actor.get_acts_manager())
	
	_update_status_bar_panel(actor.get_status())
	_add_status_effect_panels(actor.get_status().get_status_effects())

func _set_actor_name_label_text(text: String):
	_actor_name_label.text = text
func _set_actor_level_label_text(text: String):
	_actor_level_label.text = "LVL " + text

func _clear_container_children():
	for child in _details_content_panel_container.get_children():
		child.queue_free()
	for child in _abilities_content_panel_container.get_children():
		child.queue_free()
	for child in _status_effect_panel_container.get_children():
		child.queue_free()

func _add_act_content_panels(acts_manager: ActsManager):
	var act_packedscenes = [
		acts_manager.get_basic_move_packedscene(),
		acts_manager.get_enhanced_basic_move_packedscene(),
		acts_manager.get_skill_1_packedscene(),
		acts_manager.get_skill_2_packedscene()
	]
	
	for packedscene in act_packedscenes:
		if packedscene == null:
			continue
			
		var act = packedscene.instantiate()
		
		_add_content_panel(_abilities_content_panel_container, act.get_act_name(), act.get_long_description())

func _add_content_panel(container: Control, heading: String, body: String):
	var instance = CONTENT_PANEL_SCENE.instantiate()
	container.add_child(instance)
	instance.set_heading_text(heading)
	instance.set_body_text(body)

func _update_status_bar_panel(actor_status: ActorStatus):
	_status_bar_panel.set_health(actor_status.get_health(), actor_status.get_max_health())
	_status_bar_panel.set_stamina(actor_status.get_stamina(), actor_status.get_max_stamina())

func _add_status_effect_panels(status_effects: Dictionary):
	if status_effects.is_empty():
		for child in _status_effect_panel_container.get_children():
			child.queue_free()
		return
	
	var status_effect_panel_instance = STATUS_EFFECT_PANEL.instantiate()
	_status_effect_panel_container.add_child(status_effect_panel_instance)
	
	for status_effect_name in status_effects.keys():
		var status_effect_instance = status_effects[status_effect_name]
		
		status_effect_panel_instance.add_status_effect(status_effect_instance)

func _on_previous_actor_button_pressed() -> void:
	previous_actor.emit()

func _on_next_actor_button_pressed() -> void:
	next_actor.emit()
