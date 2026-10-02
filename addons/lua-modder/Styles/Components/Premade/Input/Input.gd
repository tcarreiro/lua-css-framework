extends LuaStyledBox

@onready var _line_edit: LineEdit = %Input
@onready var _label: Label = %Label
@onready var _icon_left: TextureRect = %IconLeft
@onready var _icon_right: TextureRect = %IconRight
@onready var input_wrapper: BoxContainer = %InputWrapper
@onready var background: PanelContainer = %Background

enum InputType { TEXT, NUMBER, SECRET }

var _type: InputType = InputType.TEXT
var _decimals: int = 0
var _thousand_sep: String = "."
var _decimal_sep: String = ","
var _updating := false
var _icon_path: String = ""
var _icon_side: String = "left"


func get_schema() -> Dictionary:
	return LuaStyledBox.merge_schema({
		"name": "Input",
		"props": {
			"value": {"type": TYPE_STRING, "default": ""},
			"type": {"type": TYPE_STRING, "default": "text"},
			"decimals": {"type": TYPE_INT, "default": 0},
			"width": {"type": TYPE_INT, "default": -1},
			"height": {"type": TYPE_INT, "default": -1},
			"thousand_separator": {"type": TYPE_STRING, "default": "."},
			"decimal_separator": {"type": TYPE_STRING, "default": ","},
			"disabled": {"type": TYPE_BOOL, "default": false},
			"label": {"type": TYPE_STRING, "default": ""},
			"icon": {"type": TYPE_STRING, "default": ""},
			"icon_side": {"type": TYPE_STRING, "default": "left"},
			"c_pointer": {"type": TYPE_STRING, "default": ""},
		},
		"events": ["changed", "changed_rejected", "submitted", "focus_entered", "focus_exited"],
	})


func _setup_style_target() -> void:
	_style_target.register_property(&"font_color", _line_edit)
	_style_target.register_property(&"font_size", _line_edit)
	_style_target.register_property(&"outline_color", _line_edit)
	_style_target.register_property(&"outline_size", _line_edit)
	_style_target.register_property(&"label_font_color", _label)
	_style_target.register_property(&"label_font_size", _label)
	_style_target.register_property(&"label_outline_color", _label)
	_style_target.register_property(&"label_outline_size", _label)


func _set_cursor(cursor: Control.CursorShape):
	background.mouse_default_cursor_shape = cursor
	_line_edit.mouse_default_cursor_shape = cursor


func _component_ready() -> void:
	LuaStyledBox.strip_native_stylebox(_line_edit, ["normal", "focus", "read_only"])
	_line_edit.mouse_filter = Control.MOUSE_FILTER_PASS
	_icon_left.mouse_filter = Control.MOUSE_FILTER_PASS
	_icon_right.mouse_filter = Control.MOUSE_FILTER_PASS
	_label.mouse_filter = Control.MOUSE_FILTER_PASS
	
	_line_edit.mouse_entered.connect(func():
		_set_style_state(&"hover", true)
	)
	_line_edit.mouse_exited.connect(func():
		_set_style_state(&"hover", false)
	)
	_line_edit.focus_entered.connect(func():
		_set_style_state(&"focus", true)
		emit_event("focus_entered"))
	_line_edit.focus_exited.connect(func():
		_set_style_state(&"focus", false)
		emit_event("focus_exited"))
	_line_edit.text_submitted.connect(func(t): emit_event("submitted", [t]))
	_line_edit.text_changed.connect(_on_text_changed)
	_background.gui_input.connect(_on_background_click_focus)


func _on_background_click_focus(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not props.get("disabled", false):
			_line_edit.grab_focus()


func _apply_prop(key: String, value: Variant) -> void:
	match key:
		"value":
			_set_display_value(value)
		"width":
			if value >= 0:
				input_wrapper.custom_minimum_size.x = value
		"height":
			if value >= 0:
				input_wrapper.custom_minimum_size.y = value
		"type":
			_type = InputType.get(value.to_upper(), InputType.TEXT)
			_line_edit.secret = (_type == InputType.SECRET)
			_refresh_display()
		"decimals":
			_decimals = value
			_refresh_display()
		"thousand_separator":
			_thousand_sep = value
		"decimal_separator":
			_decimal_sep = value
		"disabled":
			_line_edit.editable = not value
			_set_style_state(&"disabled", value)
		"label":
			_label.text = value
			_label.visible = (value != "")
		"icon":
			_icon_path = value
			_refresh_icon()
		"icon_side":
			_icon_side = value
			_refresh_icon()
		"c_pointer":
			# TODO create new match
			if not value is Control.CursorShape:
				_set_cursor(Control.CURSOR_IBEAM)
				return
			_set_cursor(value as Control.CursorShape)
		_:
			super._apply_prop(key, value)


func _refresh_icon() -> void:
	_icon_left.visible = false
	_icon_right.visible = false
	if _icon_path != "":
		var texture := load(_icon_path) as Texture2D
		if texture != null:
			var target := _icon_right if _icon_side == "right" else _icon_left
			target.texture = texture
			target.visible = true
	_reflow_content_margins()


func _reflow_content_margins() -> void:
	var left_reserved := _icon_left.size.x + 6.0 if _icon_left.visible else 0.0
	var right_reserved := _icon_right.size.x + 6.0 if _icon_right.visible else 0.0

	var box: StyleBox = _line_edit.get_theme_stylebox("normal")
	box.content_margin_left = left_reserved
	box.content_margin_right = right_reserved

	# Label fica logo depois do ícone esquerdo (ou colado na borda, se não tiver ícone)
	_label.position.x = left_reserved


#region Validação de NUMBER (mesma lógica desenhada antes, só renomeando _input -> _line_edit)
func _on_text_changed(new_text: String) -> void:
	if _updating:
		return

	if _type != InputType.NUMBER:
		props["value"] = new_text
		emit_event("changed", [new_text])
		return

	var normalized: Variant = _sanitize_number(new_text)
	if normalized == null:
		_updating = true
		_line_edit.text = props.get("value", "")
		_line_edit.caret_column = _line_edit.text.length()
		_updating = false
		emit_event("changed_rejected", [new_text])
		return

	var formatted: String = _format_number(normalized)
	if formatted != new_text:
		var caret := _line_edit.caret_column
		_updating = true
		_line_edit.text = formatted
		_line_edit.caret_column = clampi(caret + (formatted.length() - new_text.length()), 0, formatted.length())
		_updating = false

	props["value"] = formatted
	emit_event("changed", [_parse_number(normalized)])


func _sanitize_number(text: String) -> Variant:
	var raw := text.replace(_thousand_sep, "")
	var out := ""
	var seen_decimal := false
	for i in raw.length():
		var c := raw[i]
		if c == "-" and i == 0:
			out += c
		elif c == _decimal_sep and _decimals > 0 and not seen_decimal:
			seen_decimal = true
			out += "."
		elif c.is_valid_int():
			out += c
		else:
			return null
	return out


func _format_number(normalized: String) -> String:
	var negative := normalized.begins_with("-")
	if negative:
		normalized = normalized.substr(1)
	var parts := normalized.split(".")
	var int_part: String = parts[0]
	var dec_part: String = (parts[1] if parts.size() > 1 else "").substr(0, _decimals)

	var grouped := ""
	var count := 0
	for i in range(int_part.length() - 1, -1, -1):
		grouped = int_part[i] + grouped
		count += 1
		if count % 3 == 0 and i > 0:
			grouped = _thousand_sep + grouped

	var result := grouped
	if _decimals > 0:
		result += _decimal_sep + dec_part
	return ("-" if negative else "") + result


func _parse_number(normalized: String) -> float:
	return normalized.to_float() if normalized != "" and normalized != "-" else 0.0


func _refresh_display() -> void:
	if is_node_ready():
		_set_display_value(props.get("value", ""))


func _set_display_value(value: String) -> void:
	_updating = true
	if _type == InputType.NUMBER:
		var clean: Variant = _sanitize_number(value.replace(_decimal_sep, "."))
		_line_edit.text = _format_number(clean) if clean != null else ""
	else:
		_line_edit.text = value
	_updating = false
#endregion
