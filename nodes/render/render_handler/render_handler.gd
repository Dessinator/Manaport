extends SubViewportContainer

const PS1_RESOLUTION = Vector2i(320, 240)
const PS2_RESOLUTION = Vector2i(640, 480)
const RETRO_PC_RESOLUTION = Vector2i(800, 600)
const NATIVE_RESOLUTION = Vector2i(-1, -1)

@onready var _subviewport: SubViewport = %SubViewport

func _ready():
	_preselect_resolution()
	
	SignalBus.render_resolution_changed.connect(_set_resolution)
	get_window()

func _preselect_resolution():
	var resolution = AppSettings.get_render_resolution()
	_set_resolution(resolution)

func _set_resolution(resolution: Vector2i):
	if resolution == NATIVE_RESOLUTION:
		_subviewport.size_2d_override = get_window().size
		stretch = false
		return
	
	_subviewport.size_2d_override = resolution
	if resolution == PS1_RESOLUTION:
		stretch = true
		stretch_shrink = 3
	elif resolution == PS2_RESOLUTION:
		stretch = true
		stretch_shrink = 2
	elif resolution == RETRO_PC_RESOLUTION:
		stretch = true
		stretch_shrink = 1
