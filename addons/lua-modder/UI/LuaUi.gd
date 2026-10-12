extends Node
## Autoload: LuaUI  (depois de ComponentRegistry)
## Dono do LuaState de UI. Expõe o namespace `UI`, uma "tag" global por
## componente, e a LCSSRegistry compartilhada por todos os LuaComponent.

var state: LuaState
var lcss := LCSSRegistry.new()
var _root: Control

func _ready() -> void:
	state = LuaState.new()
	state.open_libraries()
	state.globals["UI"] = {
		"defineComponent": _lua_define_component,
		"getComponent": _lua_get_component,
		"mount": _lua_mount,
		"callMethod": _lua_call_method,
	}
	ComponentRegistry.component_registered.connect(_expose_tag)
	for component_name in ComponentRegistry.get_names():
		_expose_tag(component_name)


## Executa um .lua (é assim que componentes Lua são registrados).
func load_file(path: String) -> bool:
	var result: Variant = state.do_file(path)
	if result is LuaError:
		push_error("[LuaUI] %s: %s" % [path, result])
		return false
	return true


func set_root(root: Control) -> void:
	_root = root


## Carrega um arquivo .lcss (LCSS = a linguagem de estilo do framework).
func load_lcss(path: String) -> void:
	lcss.register_file(path)


#region Lua-facing API
func _lua_define_component(component_name: Variant, definition: Variant) -> void:
	ComponentRegistry.register_lua(str(component_name), LuaHelper.as_dict(definition))


func _lua_get_component(component_name: Variant, raw: Variant = null) -> Variant:
	return ComponentRegistry.make_element(str(component_name), LuaHelper.as_dict(raw))


func _lua_call_method(ref: Variant, method: Variant, args: Variant = null) -> Variant:
	var a: Variant = LuaHelper.normalize_lua(args)
	return ComponentRegistry.call_method(str(ref), str(method), a if a is Array else [])


func _lua_mount(el: Variant) -> void:
	var element: UIElement = el
	if _root and element:
		_root.add_child(ComponentRegistry.instantiate(element))


## Button{...}, Stats{...}: cada componente registrado vira uma função global.
func _expose_tag(component_name: String) -> void:
	if not component_name.is_valid_ascii_identifier():
		return
	state.globals[component_name] = func(raw = null):
		return ComponentRegistry.make_element(component_name, LuaHelper.as_dict(raw))
#endregion
