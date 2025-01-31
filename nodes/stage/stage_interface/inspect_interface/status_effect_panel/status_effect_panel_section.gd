extends PanelContainer

@onready var _status_effect_icon: TextureRect = %StatusEffectIcon
@onready var _status_effect_name_label: Label = %StatusEffectNameLabel
@onready var _status_effect_stacks_label: Label = %StatusEffectStacksLabel
@onready var _status_effect_duration_label: Label = %StatusEffectDurationLabel
@onready var _status_effect_description_label: Label = %StatusEffectDescriptionLabel

func set_status_effect_icon(icon: Texture2D):
	_status_effect_icon.texture = icon
func set_status_effect_name(text: String):
	_status_effect_name_label.text = text
func set_status_effect_stacks(value: int):
	_status_effect_stacks_label.text = "({value} Stacks)".format({"value" : value }) if value > 1 else "({value} Stack)".format({"value" : value })
func set_status_effect_duration(value: int):
	_status_effect_duration_label.text = "({value} Turns Left)".format({"value" : value }) if value != 0 else "(Effective Indefinitely)"
func set_status_effect_description(text: String):
	_status_effect_description_label.text = text
	
