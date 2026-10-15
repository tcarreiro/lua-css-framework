extends LuaComponent

@onready var _body: BoxContainer = %Body

func get_schema() -> Dictionary:
	var names: Array = [LCSS.DISPLAY, LCSS.GAP, LCSS.ALIGNMENT]
	names.append_array(LuaStyledBox.box_names())
	return {
		"name": "Body",
		"props": LCSS.pick(names, {LCSS.GAP: 4, LCSS.ALIGNMENT: LCSS.START}),
		"slots": {"default": "%Body"},
	}


func _apply_prop(key: String, value: Variant) -> void:
	if value == null:
		return
	match StringName(key):
		LCSS.DISPLAY:
			_body.vertical = (value != "flex")
		LCSS.ALIGNMENT:
			if LCSS.ALIGNMENTS.has(value):
				_body.alignment = LCSS.ALIGNMENTS[value]
		LCSS.GAP:
			_body.add_theme_constant_override("separation", maxi(int(value), 0))
		_:
			super._apply_prop(key, value)


#func _apply_prop(key: String, value: Variant) -> void:
	#match StringName(key):
		#LCSS.DISPLAY:
			#_items.vertical = (value != "flex")
		#LCSS.ALIGNMENT:
			#if LCSS.ALIGNMENTS.has(value):
				#_items.alignment = LCSS.ALIGNMENTS[value]
		#LCSS.GAP:
			#_items.add_theme_constant_override("separation", maxi(int(value), 0))
		#LCSS.DISABLED:
			#set_state(&"disabled", value)
		#_:
			#super._apply_prop(key, value)
