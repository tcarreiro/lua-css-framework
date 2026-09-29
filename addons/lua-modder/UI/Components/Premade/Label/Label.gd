extends LuaComponent

func get_schema() -> Dictionary:
	return {
		"name": "Label",
		"props": {"text": {"type": TYPE_STRING, "default": ""}},
	}

func _apply_prop(key: String, value: Variant) -> void:
	match key:
		"text": self.text = value
