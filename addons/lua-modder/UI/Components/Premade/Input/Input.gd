extends LuaComponent

@onready var label_container: MarginContainer = %LabelContainer
@onready var input: LineEdit = %Input
@onready var label: Label = %Label

var _type: InputType
var _decimals: int = 0
var _thousand_sep: String = "."
var _decimal_sep: String = ","
var _updating := false


func get_schema() -> Dictionary:
	return {
		"name": "Input",
		"props": {
			"label": {"type": TYPE_STRING, "default": ""},
			"value": {"type": TYPE_STRING, "default": ""},
			"placeholder": {"type": TYPE_STRING, "default": ""},
			"type": {"type": TYPE_STRING_NAME, "default": "text"},
			"disabled": {"type": TYPE_BOOL, "default": false},
			"decimals": {"type": TYPE_INT, "default": 0},
			"thousand_separator": {"type": TYPE_STRING, "default": "."},
			"decimal_separator": {"type": TYPE_STRING, "default": ","},
		},
		"events": ["changed", "changed_rejected", "editing_toggled", "submitted"],
		"methods": ["focus"],
	}


func _component_ready() -> void:
	input.text_changed.connect(_on_text_changed)
	input.focus_entered.connect(_on_focus_entered)
	input.focus_exited.connect(_on_focus_exited)

	forward_signal(input.editing_toggled, "editing_toggled")
	forward_signal(input.text_submitted, "submitted")


func _on_focus_entered() -> void:
	set_style_state(&"focus", true)


func _on_focus_exited() -> void:
	set_style_state(&"focus", false)


func _apply_prop(key: String, value: Variant) -> void:
	match key:
		"label":
			label.text = value
			label_container.visible = not value.is_empty()

		"type":
			_type = InputType.get(value.to_upper(), InputType.TEXT)
			input.secret = (_type == InputType.SECRET)
			_refresh_display()

		"placeholder":
			input.placeholder_text = str(value)

		"decimals":
			_decimals = value
			_refresh_display()

		"thousand_separator":
			_thousand_sep = value

		"decimal_separator":
			_decimal_sep = value

		"value":
			_set_display_value(value)


func _apply_disabled(value: bool) -> void:
	input.editable = not value


func _get_style_box_default_state() -> StringName:
	return &"normal"


func _get_style_box_states() -> Dictionary[StringName, StringName]:
	return {
		&"hover": &"normal",
		&"focus": &"focus",
		&"disabled": &"read_only",
	}


func _get_style_box_target() -> Control:
	return input


func _get_style_state_target() -> Control:
	return input


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
		input.text = props.get("value", "")
		input.caret_column = input.text.length()
		_updating = false
		emit_event("changed_rejected", [new_text])
		return

	var formatted: String = _format_number(normalized)

	if formatted != new_text:
		var caret := input.caret_column

		_updating = true
		input.text = formatted
		input.caret_column = clampi(
			caret + (formatted.length() - new_text.length()),
			0,
			formatted.length()
		)
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
	var dec_part: String = (
		parts[1] if parts.size() > 1 else ""
	).substr(0, _decimals)

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
		var clean: Variant = _sanitize_number(
			value.replace(_decimal_sep, ".")
		)

		input.text = _format_number(clean) if clean != null else ""
	else:
		input.text = value

	_updating = false


func focus() -> void:
	input.grab_focus()
