class_name LuaHelper extends RefCounted

static func call_by_name(lua_state: LuaState, function_name: String, args: Array = []):
	var fn = lua_state.globals[function_name]
	if not (fn is LuaFunction):
		push_error("[Lua] '%s' function not found." % function_name)
		return null

	var result = fn.invoke.callv(args)
	if result is LuaError:
		push_error("[Lua] error trying to execute '%s': %s" % [function_name, result])
		return null

	return result


static func make_callable(value) -> Callable:
	if value is Callable:
		return value

	if value is LuaFunction:
		return func(...args):
			return value.invoke.callv(args)

	push_warning("[LuaHelper] Unexpected callback value: %s" % typeof(value))
	return Callable()


static func normalize_lua(value):
	if value is LuaTable:
		var as_array: Array = value.to_array()
		if as_array.size() > 0:
			var arr := []
			for v in as_array:
				arr.append(normalize_lua(v))
			return arr
		var as_dict: Dictionary = value.to_dictionary()
		var dict := {}
		for k in as_dict:
			dict[k] = normalize_lua(as_dict[k])
		return dict
	if value is Dictionary:
		var dict := {}
		for k in value:
			dict[k] = normalize_lua(value[k])
		return dict
	if value is Array:
		var arr := []
		for v in value:
			arr.append(normalize_lua(v))
		return arr
	return value
