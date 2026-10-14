extends LuaStyledBox

@onready var _items: LuaFlowBox = %Items

func get_schema() -> Dictionary:
	var names: Array = [ComponentProps.DISPLAY, ComponentProps.GAP, ComponentProps.ALIGNMENT, ComponentProps.ALIGN_ITEMS]
	names.append_array(LuaStyledBox.box_names())
	names.append_array(ComponentProps.DRAG_GRP)
	return {
		"name": "Div",
		"props": ComponentProps.pick(names, {ComponentProps.GAP: 4, ComponentProps.ALIGNMENT: ComponentProps.START}),
		"events": ["drag_started", "drag_ended", "pressed"],
		"methods": ["reset_drag_position"],
		"slots": {"default": "%Items"},
	}


func _component_ready() -> void:
	_background.gui_input.connect(_on_click)


func _on_click(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_event("pressed")


func _apply_prop(key: String, value: Variant) -> void:
	match StringName(key):
		ComponentProps.DISPLAY:
			_items.vertical = (value != "flex")
		ComponentProps.ALIGNMENT:
			if ComponentProps.ALIGNMENTS.has(value):
				_items.alignment = ComponentProps.ALIGNMENTS[value]
		ComponentProps.GAP:
			_items.add_theme_constant_override("separation", maxi(int(value), 0))
		ComponentProps.DISABLED:
			set_state(&"disabled", value)
		ComponentProps.ALIGN_ITEMS:
			_items.align_items = StringName(str(value))
		_:
			super._apply_prop(key, value)
