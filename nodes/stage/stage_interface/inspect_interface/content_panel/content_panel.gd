class_name ContentPanel extends PanelContainer

@onready var _heading_label: Label = %HeadingLabel
@onready var _body_label: Label = %BodyLabel

var _heading_text: String
var _body_text: String

func set_heading_text(text: String):
	_heading_text = text
	_heading_label.text = _heading_text
func set_body_text(text: String):
	_body_text = text
	_body_label.text = _body_text
