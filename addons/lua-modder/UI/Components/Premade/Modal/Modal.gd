extends LuaComponent

@onready var _margin: MarginContainer = %Margin
@onready var _backdrop: PanelContainer = %Backdrop
@onready var _modal_content: BoxContainer = %ModalContent


func get_schema() -> Dictionary:
	return {
		"name": "Modal",
		"props": {
			"direction": {"type": TYPE_STRING, "default": null},
			"gap": {"type": TYPE_INT, "default": null},
			"blocking": {"type": TYPE_BOOL, "default": true},
			"backdrop-color": {
				"type": TYPE_COLOR,
				"default": Color(0, 0, 0, 0.25)
			},
			"drop_shadow_color": {"type": TYPE_COLOR, "default": null},
			"drop_shadow_size": {"type": TYPE_INT, "default": null},
			"drop_shadow_offset": {"type": TYPE_ARRAY, "default": null},
		},
		"events": ["closed"],
		"methods": ["close"],
		"slots": {"content": "%ModalContent"},
	}


func _component_ready() -> void:
	_backdrop.mouse_filter = Control.MOUSE_FILTER_PASS


func _get_style_box_default_state() -> StringName:
	return &"panel"


func _get_style_box_states() -> Dictionary[StringName, StringName]:
	return {
		&"hover": &"panel",
		&"pressed": &"panel",
		&"disabled": &"panel",
	}


func _apply_prop(key: String, value: Variant) -> void:
	match key:
		"blocking":
			_backdrop.mouse_filter = (
				Control.MOUSE_FILTER_STOP
				if value
				else Control.MOUSE_FILTER_IGNORE
			)

		"backdrop-color":
			_backdrop.self_modulate = LuaHelper.parse_color(value)


func _get_style_box_target() -> Control:
	return _backdrop


func _get_style_state_target() -> Control:
	return _backdrop


func _setup_style_target() -> void:
	_style_target.register_property(&"backdrop-color", _backdrop)
	_style_target.register_property(&"direction", _modal_content)
	_style_target.register_property(&"gap", _modal_content)
	_style_target.register_property(&"drop_shadow_color", _modal_content)
	_style_target.register_property(&"drop_shadow_size", _modal_content)
	_style_target.register_property(&"drop_shadow_offset", _modal_content)


func close() -> void:
	emit_event("closed")
	dispose()
