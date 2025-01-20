class_name StatusEffectVisual extends Control

var _attached_status_effect_instance: Dictionary

@onready var _icon: TextureRect = %IconTextureRect
@onready var _duration_label: Label = %DurationLabel
@onready var _stacks_label: Label = %StackLabel

func set_status_effect(status_effect_instance: Dictionary):
	_attached_status_effect_instance = status_effect_instance

	# _attached_status_effect_instance.stack_applied.connect(_on_stack_applied)
	# _attached_status_effect_instance.ticked.connect(_on_ticked)
	# _attached_status_effect_instance.stack_removed.connect(_on_stack_removed)

	#_attached_status_effect_instance["on_stack_applied"].connect(_on_stack_applied)
	#_attached_status_effect_instance["on_ticked"].connect(_on_ticked)
	#_attached_status_effect_instance["on_stack_removed"].connect(_on_stack_removed)

	_icon.texture = _attached_status_effect_instance["metadata"]["icon"]
	set_stacks_label(_attached_status_effect_instance["stacks"].size())
	set_duration_label(StatusEffect.get_turns_left_for_status_effect_instance(_attached_status_effect_instance))

func set_stacks_label(value: int):
	_stacks_label.text = str(value) if value != 1 else ""
func set_duration_label(value: int):
	_duration_label.text = str(value) if value != 0 else "∞"

#func _on_stack_applied(_status_effect):
	#set_stacks_label(_attached_status_effect_instance["stacks"].size())
	#set_duration_label(StatusEffect.get_turns_left_for_status_effect_instance(_attached_status_effect_instance))
#
#func _on_ticked(_status_effect):
	#set_stacks_label(_attached_status_effect_instance["stacks"].size())
	#set_duration_label(StatusEffect.get_turns_left_for_status_effect_instance(_attached_status_effect_instance))
#
#func _on_stack_removed(_status_effect):
	#set_stacks_label(_attached_status_effect_instance["stacks"].size())
	#set_duration_label(StatusEffect.get_turns_left_for_status_effect_instance(_attached_status_effect_instance))

func get_attached_status_effect_instance() -> Dictionary:
	return _attached_status_effect_instance
