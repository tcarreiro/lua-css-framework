extends LuaComponent

@onready var _margin: MarginContainer = %Margin
@onready var _background: PanelContainer = %Background
@onready var _padding: MarginContainer = %Padding
@onready var _items: BoxContainer = %Items


func get_schema() -> Dictionary:
	return {
		"name": "Div",
		"props": {
			"direction": {"type": TYPE_STRING, "default": null},
			"margin": {"type": TYPE_ARRAY, "default": null},
			"padding": {"type": TYPE_ARRAY, "default": null},
			"background_color": {"type": TYPE_COLOR, "default": null},
			"border_color": {"type": TYPE_COLOR, "default": null},
			"border_width": {"type": TYPE_ARRAY, "default": null},
			"border_radius": {"type": TYPE_ARRAY, "default": null},
			"drop_shadow_color": {"type": TYPE_COLOR, "default": null},
			"drop_shadow_size": {"type": TYPE_INT, "default": null},
			"drop_shadow_offset": {"type": TYPE_ARRAY, "default": null},
		},
		"slots": {"default": "%Items"},
	}


func _component_ready() -> void:
	_background.mouse_filter = Control.MOUSE_FILTER_PASS


func _get_style_box_default_state() -> StringName:
	return &"panel"


func _get_style_box_states() -> Dictionary[StringName, StringName]:
	return {
		&"hover": &"panel",
		&"pressed": &"panel",
		&"disabled": &"panel",
	}


func _get_style_box_target() -> Control:
	return _background


func _get_style_state_target() -> Control:
	return _background


func _setup_style_target() -> void:
	_style_target.register_property(&"direction", self)
	_style_target.register_property(&"margin", _margin)
	_style_target.register_property(&"padding", _padding)
	_style_target.register_property(&"background_color", _background)
	_style_target.register_property(&"border_color", _background)
	_style_target.register_property(&"border_width", _background)
	_style_target.register_property(&"border_radius", _background)
	_style_target.register_property(&"drop_shadow_color", _background)
	_style_target.register_property(&"drop_shadow_size", _background)
	_style_target.register_property(&"drop_shadow_offset", _background)
