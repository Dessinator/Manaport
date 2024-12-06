class_name StatusEffectVisual extends Control

var _attached_status_effect: StatusEffect

@onready var _icon: TextureRect = $Background/IconTextureRect
@onready var _duration_label: Label = $Background/DurationLabel
@onready var _stacks_label: Label = $Background/StackLabel

func set_status_effect(status_effect: StatusEffect):
	_attached_status_effect = status_effect

	_attached_status_effect.stack_applied.connect(_on_stack_applied)
	_attached_status_effect.ticked.connect(_on_ticked)
	_attached_status_effect.stack_removed.connect(_on_stack_removed)

	_icon.texture = _attached_status_effect.get_icon()
	_set_stacks_label(_attached_status_effect.get_stacks())
	_set_duration_label(_attached_status_effect.get_turns_left())

func _set_stacks_label(value: int):
	_stacks_label.text = str(value) if value != 1 else ""
func _set_duration_label(value: int):
	_duration_label.text = str(value) if value != 0 else "∞"

func _on_stack_applied(_status_effect):
	_set_stacks_label(_attached_status_effect.get_stacks())
	_set_duration_label(_attached_status_effect.get_turns_left())

func _on_ticked(_status_effect):
	_set_stacks_label(_attached_status_effect.get_stacks())
	_set_duration_label(_attached_status_effect.get_turns_left())

func _on_stack_removed(_status_effect):
	_set_stacks_label(_attached_status_effect.get_stacks())
	_set_duration_label(_attached_status_effect.get_turns_left())

func get_status_effect() -> StatusEffect:
	return _attached_status_effect
