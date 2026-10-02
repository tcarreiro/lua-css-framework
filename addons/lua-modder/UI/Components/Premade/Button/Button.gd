extends LuaComponent

@onready var _button: Button = %Button


func get_schema() -> Dictionary:
	return {
		"name": "Button",
		"props": {
			"label": {"type": TYPE_STRING, "default": ""},
			"disabled": {"type": TYPE_BOOL, "default": false},
			"background_color": {"type": TYPE_COLOR, "default": null},
			"border_color": {"type": TYPE_COLOR, "default": null},
			"border_width": {"type": TYPE_ARRAY, "default": null},
			"border_radius": {"type": TYPE_ARRAY, "default": null},
			"drop_shadow_color": {"type": TYPE_COLOR, "default": null},
			"drop_shadow_size": {"type": TYPE_INT, "default": null},
			"drop_shadow_offset": {"type": TYPE_ARRAY, "default": null},
		},
		"events": ["pressed", "mouse_entered", "mouse_exited"],
	}


func _setup_style_target() -> void:
	_style_target.register_property(&"background_color", _button)
	_style_target.register_property(&"border_color", _button)
	_style_target.register_property(&"border_width", _button)
	_style_target.register_property(&"border_radius", _button)
	_style_target.register_property(&"drop_shadow_color", _button)
	_style_target.register_property(&"drop_shadow_size", _button)
	_style_target.register_property(&"drop_shadow_offset", _button)


func _component_ready() -> void:
	forward_signal(_button.pressed, "pressed")
	forward_signal(_button.mouse_entered, "mouse_entered")
	forward_signal(_button.mouse_exited, "mouse_exited")


func _apply_disabled(value: bool) -> void:
	_button.disabled = value


func _apply_prop(key: String, value: Variant) -> void:
	match key:
		"label":
			_button.text = value


func _get_style_box_default_state() -> StringName:
	return &"normal"


func _get_style_box_states() -> Dictionary[StringName, StringName]:
	return {
		&"hover": &"hover",
		&"pressed": &"pressed",
		&"disabled": &"disabled",
	}


func _get_style_box_target() -> Control:
	return _button


func _get_style_state_target() -> Control:
	return _button
