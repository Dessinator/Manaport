class_name CharacterPlayerInput extends CharacterInputManager

@export var camera_component: CharacterCameraManager

func _input(event):
	if not event is InputEventMouseMotion:
		return
	var horizontal = -event.relative.x
	var vertical = event.relative.y
	look.emit(Vector2(horizontal, vertical))

func _process(delta):
	if (Input.is_action_pressed("move")):
		var h_rot = camera_component.get_node("horizontal").global_transform.basis.get_euler().y
		var velocity = Vector3(
			Input.get_action_strength("strafe_left") - Input.get_action_strength("strafe_right"),
			0,
			Input.get_action_strength("forward") - Input.get_action_strength("backward"))
		velocity = velocity.rotated(Vector3.UP, h_rot).normalized()
		move.emit(velocity)
	else:
		move.emit(Vector3.ZERO)
	
	if Input.is_action_just_pressed("sprint"):
		sprint.emit(true)
	if Input.is_action_just_released("sprint"):
		sprint.emit(false)
	
	if Input.is_action_just_pressed("crawl"):
		crawl.emit(true)
	if Input.is_action_just_released("crawl"):
		crawl.emit(false)
	
	
	if (Input.is_action_pressed("look")):
		var view = Vector2(
			Input.get_action_strength("look_left") - Input.get_action_strength("look_right"),
			Input.get_action_strength("look_up") - Input.get_action_strength("look_down"))
		look.emit(view)
	#if Input.is_action_pressed("primary"):
		#primary_attack.emit()
	#if Input.is_action_pressed("secondary"):
		#secondary_attack.emit()
	#if Input.is_action_just_pressed("target"):
		#target.emit()
	if Input.is_action_just_pressed("next"):
		next.emit()
	if Input.is_action_just_pressed("previous"):
		previous.emit()
	
