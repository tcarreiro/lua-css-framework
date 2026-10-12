extends LuaComponent

@onready var _body: BoxContainer = %Body

func get_schema() -> Dictionary:
	var names: Array = [ComponentProps.DISPLAY, ComponentProps.GAP, ComponentProps.ALIGNMENT]
	names.append_array(LuaStyledBox.box_names())
	return {
		"name": "Body",
		"props": ComponentProps.pick(names, {ComponentProps.GAP: 4, ComponentProps.ALIGNMENT: ComponentProps.START}),
		"slots": {"default": "%Body"},
	}


func _apply_prop(key: String, value: Variant) -> void:
	if value == null:
		return
	match StringName(key):
		ComponentProps.DISPLAY:
			_body.vertical = (value != "flex")
		ComponentProps.ALIGNMENT:
			if ComponentProps.ALIGNMENTS.has(value):
				_body.alignment = ComponentProps.ALIGNMENTS[value]
		ComponentProps.GAP:
			_body.add_theme_constant_override("separation", maxi(int(value), 0))
		_:
			super._apply_prop(key, value)


#func _apply_prop(key: String, value: Variant) -> void:
	#match StringName(key):
		#ComponentProps.DISPLAY:
			#_items.vertical = (value != "flex")
		#ComponentProps.ALIGNMENT:
			#if ComponentProps.ALIGNMENTS.has(value):
				#_items.alignment = ComponentProps.ALIGNMENTS[value]
		#ComponentProps.GAP:
			#_items.add_theme_constant_override("separation", maxi(int(value), 0))
		#ComponentProps.DISABLED:
			#set_state(&"disabled", value)
		#_:
			#super._apply_prop(key, value)
