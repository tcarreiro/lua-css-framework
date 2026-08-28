class_name LuaHelpers extends RefCounted

static func call_by_name(lua_state: LuaState, function_name: String, args: Array = []):
	var fn = lua_state.globals[function_name]
	if not (fn is LuaFunction):
		push_error("[Lua] Função '%s' não encontrada no state." % function_name)
		return null

	var result = fn.invoke.callv(args)
	if result is LuaError:
		push_error("[Lua] Erro ao executar '%s': %s" % [function_name, result])
		return null

	return result
