extends Node
# Autoload: LuaEventBridge
# Canal genérico de eventos Lua -> GDScript. Não sabe nada de UI.

signal lua_event(event_name: String, data)


## Registra o global "Host" no LuaState informado, permitindo que
## scripts Lua chamem Host.emit(nome, dado) para notificar o GDScript.
func register_into(state: LuaState) -> void:
	state.globals["Host"] = {
		"emit": func(event_name, data):
			lua_event.emit(str(event_name), LuaHelpers.normalize_lua(data))
	}
