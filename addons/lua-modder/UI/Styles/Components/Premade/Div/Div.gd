extends LuaStyledBox

@onready var _items: LuaFlowBox = %Items

func get_schema() -> Dictionary:
	var names: Array = [ComponentProps.DISPLAY, ComponentProps.GAP]
	names.append_array(LuaStyledBox.box_names())
	names.append_array(ComponentProps.DRAG_GRP)
	return {
		"name": "Div",
		"props": ComponentProps.pick(names, {ComponentProps.GAP: 4}),
		"events": ["drag_started", "drag_ended"],
		"methods": ["reset_drag_position"],
		"slots": {"default": "%Items"},
	}


func _apply_prop(key: String, value: Variant) -> void:
	match StringName(key):
		ComponentProps.DISPLAY:
			_items.vertical = (value != "flex")
		ComponentProps.GAP:
			_items.add_theme_constant_override("separation", maxi(int(value), 0))
		ComponentProps.DISABLED:
			set_state(&"disabled", value)
		_:
			super._apply_prop(key, value)
