extends LuaComponent

@onready var _backdrop: Panel = %Backdrop

func get_schema() -> Dictionary:
	return {
		"name": "Modal",
		"props": {
			"blocking": {"type": TYPE_BOOL, "default": true},
			"backdrop-color": {"type": TYPE_COLOR, "default": Color(0,0,0,.25)}
			},
		"events": ["closed"],
		"methods": ["close"],
		"slots": {"content": "%ContentSlot"},
	}


func _apply_prop(key: String, value: Variant) -> void:
	match key:
		"blocking":
			_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP if value else Control.MOUSE_FILTER_IGNORE
		"backdrop-color":
			_backdrop.self_modulate = LuaHelper.parse_color(value)


## Exposto ao Lua via UI.callMethod(ref, "close").
func close() -> void:
	emit_event("closed")
	dispose()
