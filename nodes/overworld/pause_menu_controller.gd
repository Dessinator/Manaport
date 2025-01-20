extends PauseMenuController

@export var _create_at_top_of_scene_tree: bool = true
@export var _use_input: bool = true
@export var _use_signal: bool = false

func _on_pause():
	if not _use_signal:
		return
	
	_handle_pause()

func _unhandled_input(event):
	if not _use_input:
		return
	
	if event.is_action_pressed("ui_cancel"):
		_handle_pause()

func _handle_pause():
	if not focused_viewport:
		focused_viewport = get_viewport()
	var _initial_focus_control = focused_viewport.gui_get_focus_owner()
	var current_menu = pause_menu_packed.instantiate()
	get_tree().current_scene.call_deferred("add_child", current_menu)
	if _create_at_top_of_scene_tree:
		get_tree().current_scene.call_deferred("move_child", current_menu, 0)
	var last_mouse_mode = Input.mouse_mode
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	await current_menu.tree_exited
	Input.set_mouse_mode(last_mouse_mode)
	if is_inside_tree() and _initial_focus_control:
		_initial_focus_control.grab_focus()
