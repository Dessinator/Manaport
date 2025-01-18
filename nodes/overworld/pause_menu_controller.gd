extends PauseMenuController

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if not focused_viewport:
			focused_viewport = get_viewport()
		var _initial_focus_control = focused_viewport.gui_get_focus_owner()
		var current_menu = pause_menu_packed.instantiate()
		get_tree().current_scene.call_deferred("add_child", current_menu)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		await current_menu.tree_exited
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if is_inside_tree() and _initial_focus_control:
			_initial_focus_control.grab_focus()
