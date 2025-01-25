extends VideoOptionsMenu


func _preselect_resolution(window : Window):
	%ResolutionControl.value = AppSettings.get_render_resolution()
	%AffineMappingControl.value = AppSettings.get_affine_mapping()
	%JitterStrengthControl.value = AppSettings.get_jitter_strength()
	%DitheringControl.value = AppSettings.get_dithering()
	%LimitColorsControl.value = AppSettings.get_limit_colors()

func _update_resolution_options_enabled(window : Window):
	%ResolutionControl.editable = true
	%ResolutionControl.tooltip_text = \
			"Changes the 3D render resolution. \n
			(This will not affect UI, which is rendered at your native resolution.)"

func _on_resolution_control_setting_changed(value):
	AppSettings.set_render_resolution(value)
func _on_affine_mapping_control_setting_changed(value):
	AppSettings.set_affine_mapping(value)
func _on_jitter_strength_control_setting_changed(value):
	AppSettings.set_jitter_strength(value)
func _on_dithering_control_setting_changed(value):
	AppSettings.set_dithering(value)
func _on_limit_colors_control_setting_changed(value):
	AppSettings.set_limit_colors(value)
