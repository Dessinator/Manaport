class_name 	ActButton extends Control

@onready var _button: Button = $Button

@onready var _info_background: Control = $Button/InfoBackground
@onready var _info_label: RichTextLabel = $Button/InfoBackground/Info

@export var _button_text: String
@export var _show_info: bool = true

@export var _element: Element.Type
@export var _act_type: Act.Type
@export var _does_recover_stamina: bool
@export var _stamina_modifier: int

@export var _item_mode: bool = false
@export var _item_quantity: int = 0

func _ready():
	set_button_text(_button_text)
	set_info_visible(_show_info)
	set_element(_element)
	set_act_type(_act_type)
	set_stamina_modifier(_does_recover_stamina, _stamina_modifier)
	set_item_quantity(_element)

	update_info_text()

func set_button_text(text: String):
	_button.text = text

func set_info_visible(is_visible: bool):
	_info_background.visible = is_visible
	_info_label.visible = is_visible

func set_element(element: Element.Type):
	_element = element
func set_act_type(act_type: Act.Type):
	_act_type = act_type
func set_stamina_modifier(does_recover_stamina: bool, stamina_modifier: int):
	_does_recover_stamina = does_recover_stamina
	_stamina_modifier = stamina_modifier
func set_item_quantity(quantity: int):
	_item_quantity = quantity

func set_unavailable():
	_button.disabled = true

func update_info_text():
	# var item_quantity_string = "x" + str(_item_quantity)

	var element_string = str(Element.ELEMENT_TYPE_STRINGS[_element])
	var act_type_string = str(Act.ACT_TYPE_STRINGS[_act_type])
	var recover_stamina_string = "-"
	if _does_recover_stamina:
		recover_stamina_string = "+"

	_info_label.text = "[center]{element} • {act_type} • {does_recover_stamina}{stamina_modifier} STMA[/center]".format(
		{
			"element": element_string,
			"act_type": act_type_string,
			"does_recover_stamina": recover_stamina_string,
			"stamina_modifier": str(_stamina_modifier)
		})

func get_button() -> Button:
	return _button