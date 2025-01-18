extends MiniOptionsMenu

@onready var _render_resolution_control = %RenderResolutionControl

func _update_ui():
	super()
	_render_resolution_control.value = AppSettings.get_render_resolution()

func _on_render_resolution_control_setting_changed(value):
	AppSettings.set_render_resolution(value)
