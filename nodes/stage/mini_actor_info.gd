class_name MiniActorInfo extends Control

@onready var _HLTH_bar: Bar = $Control/BarsBackground/VBoxContainer/HLTHBar
@onready var _STMA_bar: Bar = $Control/BarsBackground/VBoxContainer/STMABar

@onready var _status_effect_container = $"Control/StatusEffectsBackground/HBoxContainer"
@onready var _status_effect_container_fade = $"Control/StatusEffectsBackground/TextureRect"

# @onready var _animation_player: AnimationPlayer = $AnimationPlayer

# func rise():
# 	_animation_player.play("rise")
# func fall():
# 	_animation_player.play("fall")

# func set_portrait(portrait: Texture2D):
# 	_portrait_texture_rect.texture = portrait

func get_hlth_bar() -> Bar:
	return _HLTH_bar
func get_stma_bar() -> Bar:
	return _STMA_bar

func get_status_effect_container() -> HBoxContainer:
	return _status_effect_container