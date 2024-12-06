class_name ActorVisualManager extends Node3D

const STATUS_EFFECT_VISUAL_SCENE = preload("res://content/stage/status_effect_visual.tscn")

@export var _portrait: Texture2D
@export var _action_order_icon: Texture2D

# @export var _actor_stats: ActorStats
@export var _select_actor_arrow: Node3D
@export var _mini_actor_info_container: Node3D

var _actor_status: ActorStatus

var _actor_info: ActorInfo
var _mini_actor_info: MiniActorInfo
var _action_order_visual: ActionOrderVisual

var _status_effect_visuals: Array = []
var _status_numbers: Array = []

func attach_actor_info(actor_info: ActorInfo):
	_actor_info = actor_info
	
	_actor_info.set_portrait(_portrait)
	
	_update_actor_info_hlth_bar()
	_update_actor_info_stma_bar()

	_actor_status.health_modified.connect(_update_actor_info_hlth_bar)
	_actor_status.stamina_modified.connect(_update_actor_info_stma_bar)
func attach_mini_actor_info(mini_actor_info: MiniActorInfo):
	_mini_actor_info = mini_actor_info

	_update_mini_actor_info_hlth_bar()
	_update_mini_actor_info_stma_bar()

	_actor_status.health_modified.connect(_update_mini_actor_info_hlth_bar)
	_actor_status.stamina_modified.connect(_update_mini_actor_info_stma_bar)

func rise():
	if _actor_info:
		_actor_info.rise()
func fall():
	if _actor_info:
		_actor_info.fall()

func show_select_actor_arrow():
	_select_actor_arrow.visible = true
func hide_select_actor_arrow():
	_select_actor_arrow.visible = false

func _update_actor_info_hlth_bar(old = 0, new = 0):
	var hlth_bar = _actor_info.get_hlth_bar()
	hlth_bar.set_max_value(_actor_status.get_max_health())
	hlth_bar.set_value(_actor_status.get_health())
	hlth_bar.set_label_value(_actor_status.get_health())
func _update_actor_info_stma_bar(old = 0, new = 0):
	var stma_bar = _actor_info.get_stma_bar()
	stma_bar.set_max_value(_actor_status.get_max_stamina())
	stma_bar.set_value(_actor_status.get_stamina())
	stma_bar.set_label_value(_actor_status.get_stamina())

func _update_mini_actor_info_hlth_bar(old = 0, new = 0):
	var hlth_bar = _mini_actor_info.get_hlth_bar()
	hlth_bar.set_max_value(_actor_status.get_max_health())
	hlth_bar.set_value(_actor_status.get_health())
	hlth_bar.set_label_value(_actor_status.get_health())
func _update_mini_actor_info_stma_bar(old = 0, new = 0):
	var stma_bar = _mini_actor_info.get_stma_bar()
	stma_bar.set_max_value(_actor_status.get_max_stamina())
	stma_bar.set_value(_actor_status.get_stamina())
	stma_bar.set_label_value(_actor_status.get_stamina())

func _on_status_effect_applied(status_effect: StatusEffect):
	var instance = STATUS_EFFECT_VISUAL_SCENE.instantiate()

	if _actor_info:
		_actor_info.get_status_effect_container().add_child(instance)
	if _mini_actor_info:
		_mini_actor_info.get_status_effect_container().add_child(instance)
	
	_status_effect_visuals.append(instance)
	instance.set_status_effect(status_effect)
func _on_status_effect_removed(status_effect: StatusEffect):
	var visual = _status_effect_visuals.filter(func(vis): return vis.get_status_effect() == status_effect)[0]
	_status_effect_visuals.erase(visual)
	visual.queue_free()

func _on_damaged(amount: int, crit: bool):
	var status_number = StatusNumber.create_status_number(self, {"amount": amount, "crit": crit})
	_status_numbers.append(status_number)
func _on_healed(amount: int):
	pass

func get_portrait() -> Texture2D:
	return _portrait
func get_action_order_icon() -> Texture2D:
	return _action_order_icon
func get_actor_info() -> ActorInfo:
	return _actor_info
func get_mini_actor_info_container() -> Node3D:
	return _mini_actor_info_container
