extends MiniOptionsMenu

@onready var _render_resolution_control: OptionControl = %RenderResolutionControl
@onready var _affine_mapping_control: OptionControl = %AffineMappingControl
@onready var _jitter_strength_control: OptionControl = %JitterStrengthControl
@onready var _dithering_control: OptionControl = %DitheringControl
@onready var _limit_colors_control: OptionControl = %LimitColorsControl

func _update_ui():
	super()
	_render_resolution_control.value = AppSettings.get_render_resolution()
	_affine_mapping_control.value = AppSettings.get_affine_mapping()
	_jitter_strength_control.value = AppSettings.get_jitter_strength()
	_dithering_control.value = AppSettings.get_dithering()
	_limit_colors_control.value = AppSettings.get_limit_colors()

func _on_render_resolution_control_setting_changed(value):
	AppSettings.set_render_resolution(value)
func _on_affine_mapping_control_setting_changed(value):
	AppSettings.set_affine_mapping(value)
func _on_jitter_strength_control_setting_changed(value):
	AppSettings.set_jitter_strength(value)
func _on_dithering_control_setting_changed(value):
	AppSettings.set_dithering(value)
func _on_limit_colors_control_setting_changed(value):
	AppSettings.set_limit_colors(value)
