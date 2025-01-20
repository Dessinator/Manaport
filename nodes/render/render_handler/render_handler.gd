extends SubViewportContainer

const PS1_RESOLUTION = Vector2i(320, 240)
const PS2_RESOLUTION = Vector2i(640, 480)
const PS3_RESOLUTION = Vector2i(960, 720)
const GAME_RESOLUTION = Vector2i(1280, 960)

@onready var _subviewport: SubViewport = %SubViewport

func _ready():
	_preselect_resolution()
	
	SignalBus.render_resolution_changed.connect(_set_resolution)
	get_window()

func _preselect_resolution():
	var resolution = AppSettings.get_render_resolution()
	_set_resolution(resolution)

func _set_resolution(resolution: Vector2i):
	_subviewport.size_2d_override = resolution
	if resolution == PS1_RESOLUTION:
		stretch = true
		stretch_shrink = 4
	elif resolution == PS2_RESOLUTION:
		stretch = true
		stretch_shrink = 3
	elif resolution == PS3_RESOLUTION:
		stretch = true
		stretch_shrink = 2
	elif resolution == GAME_RESOLUTION:
		stretch = true
		stretch_shrink = 1
		return
