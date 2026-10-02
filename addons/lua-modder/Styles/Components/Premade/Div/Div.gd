extends LuaStyledBox

@onready var _items: LuaFlowBox = %Items


func get_schema() -> Dictionary:
	return LuaStyledBox.merge_schema({
		"name": "Div",
		"props": {
			"display": {"type": TYPE_STRING, "default": "block"},
			"gap": {"type": TYPE_INT, "default": 4},
		},
		"slots": {"default": "%Items"},
	})


func _apply_prop(key: String, value: Variant) -> void:
	match key:
		"display":
			_items.vertical = (value != "flex")
		"disabled":
			_set_style_state(&"disabled", value)
		"gap":
			if not value is int or value < 0:
				return
			_items.add_theme_constant_override("separation", value)
		_:
			super._apply_prop(key, value)
