class_name StageCamera extends Camera3D

signal start_hold(result: Dictionary)
signal hold(result: Dictionary)
signal end_hold(result: Dictionary)
signal single_click(result: Dictionary)
signal double_click(result: Dictionary)

const RAY_LENGTH: int = 1000

@onready var _double_click_timer: Timer = $DoubleClickTimer

var _waiting_for_double_click: bool = false
var _holding: bool = false

func _ready() -> void:
	_double_click_timer.timeout.connect(func(): _waiting_for_double_click = false)

func _process(_delta) -> void:
	if Input.is_action_just_pressed("select") and _waiting_for_double_click:
		double_click.emit(shoot_ray())
	elif Input.is_action_just_pressed("select") and not _waiting_for_double_click:
		single_click.emit(shoot_ray())
		_waiting_for_double_click = true
		_double_click_timer.start()
	
	if Input.is_action_just_released("select"):
		if _holding:
			_holding = false
			end_hold.emit(shoot_ray())
	if Input.is_action_pressed("select"):
		if not _holding:
			_holding = true
			start_hold.emit(shoot_ray())
		else:
			hold.emit(shoot_ray())

func shoot_ray() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * RAY_LENGTH
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var result = space.intersect_ray(ray_query)
	
	return result
