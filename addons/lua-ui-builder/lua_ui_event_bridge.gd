extends Node
# Autoload: LuaEventBridge
# Canal genérico de eventos Lua -> GDScript. Não sabe nada de UI.

signal lua_event(event_name: String, data)


## Registra o global "Host" no LuaState informado, permitindo que
## scripts Lua chamem Host.emit(nome, dado) para notificar o GDScript.
func register_into(state: LuaState) -> void:
	state.globals["Host"] = {
		"emit": func(event_name, data):
			lua_event.emit(str(event_name), _normalize(data))
	}


func _normalize(value):
	if value is LuaTable:
		var as_array: Array = value.to_array()
		if as_array.size() > 0:
			var arr := []
			for v in as_array:
				arr.append(_normalize(v))
			return arr
		var as_dict: Dictionary = value.to_dictionary()
		var dict := {}
		for k in as_dict:
			dict[k] = _normalize(as_dict[k])
		return dict
	if value is Dictionary:
		var dict := {}
		for k in value:
			dict[k] = _normalize(value[k])
		return dict
	if value is Array:
		var arr := []
		for v in value:
			arr.append(_normalize(v))
		return arr
	return value
