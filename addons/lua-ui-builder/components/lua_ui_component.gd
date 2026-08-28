class_name LuaUiComponent extends RefCounted


func get_type_name() -> String:
	push_error("[LuaUiComponent] get_type_name() não foi implementado.")
	return ""


func build(_definition: Dictionary, _context: LuaUiBuildContext) -> Control:
	push_error("[LuaUiComponent] build() não foi implementado.")
	return null
