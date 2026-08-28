extends Node

# Autoload: LuaUiBridge
#
# Responsável exclusivamente pela ponte entre:
#	LuaState / lua-gdextension
#	e
#	o framework de UI.


var _lua_state: LuaState
var _ui_manager := LuaUiManager.new()


func _ready() -> void:
	get_or_create_state()


# ---------------------------------------------------------------------------
# Estado Lua
# ---------------------------------------------------------------------------

func get_or_create_state(shared_state: LuaState = null) -> LuaState:
	if _lua_state != null:
		return _lua_state

	if shared_state != null:
		_lua_state = shared_state
	else:
		_lua_state = LuaState.new()
		_lua_state.open_libraries()

	_register_lua_api(_lua_state)

	return _lua_state


func dispose_state() -> void:
	_ui_manager.dispose()
	_lua_state = null


# ---------------------------------------------------------------------------
# Pontos de extensão do framework
# ---------------------------------------------------------------------------

func set_translation_resolver(fn: Callable) -> void:
	_ui_manager.set_translation_resolver(fn)


func register_theme(theme_name: String, theme: Theme) -> void:
	_ui_manager.register_theme(theme_name, theme)


func register_animation(name: String, preset: LuaUiAnimationPreset) -> void:
	_ui_manager.register_animation(name, preset)


func register_sound(name: String, stream: AudioStream) -> void:
	_ui_manager.register_sound(name, stream)


func set_ui_root(root: Control) -> void:
	_ui_manager.set_ui_root(root)


func register_component(component: LuaUiComponent) -> void:
	_ui_manager.register_component(component)


# ---------------------------------------------------------------------------
# API exposta ao Lua
# ---------------------------------------------------------------------------

func _register_lua_api(state: LuaState) -> void:
	state.globals["UI"] = {
		"open": func(raw_definition):
			return open_ui(state, raw_definition),

		"close": Callable(_ui_manager, "close"),

		"close_current": func():
			_ui_manager.close_current(state),

		"get_current_value": func(component_id):
			return _ui_manager.get_current_value(state, component_id),

		"set_current_value": func(component_id, value):
			_ui_manager.set_current_value(state, component_id, value),

		"get_value": Callable(_ui_manager, "get_value"),
		"set_value": Callable(_ui_manager, "set_value"),
	}


# ---------------------------------------------------------------------------
# Entrada pública utilizada pelo host
# ---------------------------------------------------------------------------

func open_ui(state: LuaState, raw_definition) -> int:
	var definition = _normalize(raw_definition)

	if not definition is Dictionary:
		push_error("[LuaUiBridge] UI.open espera uma tabela de definição.")
		return -1

	return _ui_manager.open(definition, state)


func open_at(state: LuaState, raw_definition, anchor_control: Control) -> int:
	var definition = _normalize(raw_definition)

	if not definition is Dictionary:
		push_error("[LuaUiBridge] UI.open_at espera uma tabela de definição.")
		return -1

	return _ui_manager.open_at(definition, anchor_control, state)


func close(handle_id: int) -> void:
	_ui_manager.close(handle_id)



# ---------------------------------------------------------------------------
# Normalização LuaTable / LuaFunction → tipos nativos
# ---------------------------------------------------------------------------

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
