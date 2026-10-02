extends LuaStyledBox

@onready var _btn: Button = %Button

func get_schema() -> Dictionary:
	return LuaStyledBox.merge_schema({
		"name": "Button",
		"props": {
			"label": {"type": TYPE_STRING, "default": ""},
			"disabled": {"type": TYPE_BOOL, "default": false},
		},
		"events": ["pressed", "mouse_entered", "mouse_exited", "focus_entered", "focus_exited"],
	})


func _component_ready() -> void:
	LuaStyledBox.strip_native_stylebox(_btn, ["normal", "hover", "pressed", "disabled", "focus"])
	_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	forward_signal(_btn.focus_entered, "focus_entered")
	forward_signal(_btn.focus_exited, "focus_exited")
	_background.gui_input.connect(_on_click)


func _on_click(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if props.get("disabled", false):
			return
		emit_event("pressed")


func _setup_style_target() -> void:
	_style_target.register_property(&"font_color", _btn)


func _apply_prop(key: String, value: Variant) -> void:
	match key:
		"label":
			_btn.text = value
		"disabled":
			_btn.disabled = value
			_set_style_state(&"disabled", value)
		_:
			super._apply_prop(key, value)
