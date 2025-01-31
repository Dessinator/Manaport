class_name StatusBarPanel extends PanelContainer

@onready var _htlh_bar: Bar = %HTLHBar
@onready var _stma_bar: Bar = %STMABar

var _health: int
var _max_health: int
var _stamina: int
var _max_stamina: int

func set_health(value: int, max_value: int):
	_health = value
	_max_health = max_value
	_htlh_bar.set_label_value(_health)
	_htlh_bar.set_max_value(_max_health)
	_htlh_bar.set_value(_health)
func set_stamina(value: int, max_value: int):
	_stamina = value
	_max_stamina = max_value
	_stma_bar.set_label_value(_stamina)
	_stma_bar.set_max_value(_max_stamina)
	_stma_bar.set_value(_stamina)
