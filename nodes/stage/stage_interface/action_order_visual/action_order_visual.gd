class_name ActionOrderVisual extends Control

@onready var _icon_texture_rect = %IconTextureRect
@onready var _count_label = %CountLabel

var _count: int = 1
var _attached_actors: Array:
	set(value):
		_attached_actors = value
		set_count(_attached_actors.size())

func set_icon(icon: Texture2D):
	_icon_texture_rect.texture = icon
func set_count(count: int):
	_count = count
	if _count == 1:
		_count_label.text = ""
		return
	_count_label.text = str(_count)

func attach_actor(actor: Actor):
	_attached_actors.append(actor)
	set_count(_attached_actors.size())

func get_count() -> int:
	return _count
func get_attached_actors() -> Array:
	return _attached_actors
func set_attached_actors(actors: Array):
	_attached_actors = actors
