extends LuaStyledBox

@onready var _items: LuaFlowBox = %Items

func get_schema() -> Dictionary:
	var names: Array = [LCSS.DISPLAY, LCSS.GAP, LCSS.ALIGNMENT, LCSS.ALIGN_ITEMS]
	names.append_array(LuaStyledBox.box_names())
	names.append_array(LCSS.DRAG_GRP)
	return {
		"name": "Div",
		"props": LCSS.pick(names, {LCSS.GAP: 4, LCSS.ALIGNMENT: LCSS.START}),
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
		LCSS.DISPLAY:
			_items.vertical = (value != "flex")
		LCSS.ALIGNMENT:
			if LCSS.ALIGNMENTS.has(value):
				_items.alignment = LCSS.ALIGNMENTS[value]
		LCSS.GAP:
			_items.add_theme_constant_override("separation", maxi(int(value), 0))
		LCSS.DISABLED:
			set_state(&"disabled", value)
		LCSS.ALIGN_ITEMS:
			_items.align_items = StringName(str(value))
		_:
			super._apply_prop(key, value)
