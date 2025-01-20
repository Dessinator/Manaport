class_name MiniActorInfo extends Control

@onready var _HLTH_bar: Bar = %HTLHBar
@onready var _STMA_bar: Bar = %STMABar

@onready var _status_effect_container = %StatusEffectContainer
@onready var _status_effect_container_fade = %FadeTextureRect

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
