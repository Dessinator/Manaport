class_name ActorInfo extends Control

@export var _portrait: Texture2D

@onready var _portrait_texture_rect: TextureRect = $Background/PortraitBackground/TextureRect

@onready var _HLTH_bar: Bar = $Background/BarsBackground/VBoxContainer/HLTHBar
@onready var _STMA_bar: Bar = $Background/BarsBackground/VBoxContainer/STMABar

@onready var _status_effect_container = $"Background/StatusEffectsBackground/VBoxContainer"
@onready var _status_effect_container_fade = $"Background/StatusEffectsBackground/TextureRect"

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

func rise():
	_animation_player.play("rise")
func fall():
	_animation_player.play("fall")

func set_portrait(portrait: Texture2D):
	_portrait_texture_rect.texture = portrait

func get_hlth_bar() -> Bar:
	return _HLTH_bar
func get_stma_bar() -> Bar:
	return _STMA_bar

func get_status_effect_container() -> VBoxContainer:
	return _status_effect_container
