extends VideoOptionsMenu


func _preselect_resolution(window : Window):
	%ResolutionControl.value = AppSettings.get_render_resolution()

func _update_resolution_options_enabled(window : Window):
	%ResolutionControl.editable = true
	%ResolutionControl.tooltip_text = \
			"Changes the 3D render resolution. \n
			(This will not affect UI, which is rendered at your native resolution.)"

func _on_resolution_control_setting_changed(value):
	AppSettings.set_render_resolution(value)
