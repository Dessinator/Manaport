class_name CharacterPlayerInputManager extends CharacterInputManager

@export var _camera_manager: CharacterCameraManager

func _input(event):
	if not event is InputEventMouseMotion:
		return
	var horizontal = -event.relative.x
	var vertical = event.relative.y
	on_look.emit(Vector2(horizontal, vertical))

func _process(delta):
	if (Input.is_action_pressed("move")):
		var h_rot = _camera_manager.get_node("horizontal").global_transform.basis.get_euler().y
		var velocity = Vector3(
			Input.get_action_strength("left") - Input.get_action_strength("right"),
			0,
			Input.get_action_strength("up") - Input.get_action_strength("down"))
		velocity = velocity.rotated(Vector3.UP, h_rot).normalized()
		on_move.emit(velocity)
	else:
		on_move.emit(Vector3.ZERO)
	
	if Input.is_action_just_pressed("sprint"):
		on_sprint.emit(true)
	if Input.is_action_just_released("sprint"):
		on_sprint.emit(false)
	
	if Input.is_action_just_pressed("crawl"):
		on_crawl.emit(true)
	if Input.is_action_just_released("crawl"):
		on_crawl.emit(false)
	
	
	if (Input.is_action_pressed("look")):
		var view = Vector2(
			Input.get_action_strength("look_left") - Input.get_action_strength("look_right"),
			Input.get_action_strength("look_up") - Input.get_action_strength("look_down"))
		on_look.emit(view)
	if Input.is_action_just_pressed("next"):
		on_next.emit()
	if Input.is_action_just_pressed("previous"):
		on_previous.emit()

func set_camera_manager(camera_manager: CharacterCameraManager):
	_camera_manager = camera_manager
