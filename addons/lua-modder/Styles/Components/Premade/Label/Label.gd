extends LuaComponent


func get_schema() -> Dictionary:
	return {
		"name": "Label",
		"props": {
			"text": {"type": TYPE_STRING, "default": ""},
		},
	}


func _setup_style_target() -> void:
	_style_target.register_property(&"font_color", self)
	_style_target.register_property(&"font_size", self)
	_style_target.register_property(&"outline_color", self)
	_style_target.register_property(&"outline_thickness", self)


func _apply_prop(key: String, value: Variant) -> void:
	match key:
		"text":
			self.text = value
