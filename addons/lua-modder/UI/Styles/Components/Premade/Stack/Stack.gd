extends LuaStyledBox

func get_schema() -> Dictionary:
	return {
		"name": "Stack",
		"props": LCSS.pick(LuaStyledBox.box_names()),
		"slots": {"default": "%Items"},
	}
