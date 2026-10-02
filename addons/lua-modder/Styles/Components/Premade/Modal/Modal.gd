extends LuaComponent

@onready var _backdrop: PanelContainer = %Backdrop
@onready var _content_slot: MarginContainer = %ModalContent
@onready var _background: PanelContainer = %Background


func get_schema() -> Dictionary:
	return {
		"name": "Modal",
		"props": {
			"blocking": {"type": TYPE_BOOL, "default": true},
			"backdrop_color": {"type": TYPE_COLOR, "default": Color(0, 0, 0, 0.25)},
			"margin": {"type": TYPE_NIL, "default": null},
			"drop_shadow_color": {"type": TYPE_COLOR, "default": null},
			"drop_shadow_size": {"type": TYPE_INT, "default": null},
			"drop_shadow_offset": {"type": TYPE_NIL, "default": null},
		},
		"events": ["closed"],
		"methods": ["close"],
		"slots": {"content": "%Background"},
	}


func _ready() -> void:
	_style_target.register_property(&"margin", _content_slot)
	_style_target.register_property(&"drop_shadow_color", _background)
	_style_target.register_property(&"drop_shadow_size", _background)
	_style_target.register_property(&"drop_shadow_offset", _background)
	super._ready()


func _component_ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)


func _apply_prop(key: String, value: Variant) -> void:
	match key:
		"blocking":
			_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP if value else Control.MOUSE_FILTER_IGNORE
		"backdrop_color":
			LCSSAppliers.apply(&"background_color", value, _backdrop)
		_:
			super._apply_prop(key, value)


func close() -> void:
	emit_event("closed")
	dispose()
