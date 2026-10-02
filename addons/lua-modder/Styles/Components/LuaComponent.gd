class_name LuaComponent extends Control
## Raiz de todo componente. NÃO força tamanho/posição — quem decide isso é o
## pai (LuaFlowBox aplica block/flex; um componente fora de um slot flow usa
## o tamanho natural do próprio root, como sempre foi no Godot).

signal prop_changed(key: String, value: Variant)
signal disposing

var component_name: String = ""
var props: Dictionary = {}
var handlers: Dictionary = {}
var component_id: String = ""

## Classes LCSS atribuídas via prop "class".
var style_classes: Array[StringName] = []

var _style: LCSSStyle
var _style_target := LCSSStyleTarget.new()
var _style_overrides: Dictionary[StringName, Variant] = {}

var _schema: Dictionary = {}
var _is_ready := false
var _slot_cache: Dictionary = {}


#region Override points
func get_schema() -> Dictionary:
	return {}

func _apply_prop(key: String, value: Variant) -> void:
	var prop := StringName(key)
	if value != null and _style_target.has_property(prop):
		_style_overrides[prop] = value
		_style_target.apply_style(_style, _style_overrides)

func _component_ready() -> void:
	pass
#endregion


#region Lifecycle
func setup(p_name: String, p_props: Dictionary, p_handlers: Dictionary, p_schema: Dictionary) -> void:
	component_name = p_name
	props = p_props
	handlers = p_handlers
	_schema = p_schema


func _ready() -> void:
	for key: String in props:
		_apply_prop_internal(key, props[key])
	_is_ready = true
	_component_ready()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		handlers.clear()


func dispose() -> void:
	disposing.emit()
	handlers.clear()
	queue_free()
#endregion


#region Props
func set_prop(key: String, value: Variant) -> void:
	var def: Dictionary = ComponentRegistry.get_prop_def(_schema, key)
	if def.is_empty():
		push_warning("[LuaComponent:%s] prop desconhecida '%s'" % [component_name, key])
		return
	props[key] = ComponentRegistry.coerce(value, def)
	if _is_ready:
		_apply_prop_internal(key, props[key])
		prop_changed.emit(key, props[key])


func _apply_prop_internal(key: String, value: Variant) -> void:
	match key:
		"id":
			component_id = value
			if value != "":
				name = value
		"class":
			style_classes = LuaHelper.parse_style_classes(value)
			_refresh_style()
		"visible":
			visible = value
		"tooltip":
			tooltip_text = value
		_:
			_apply_prop(key, value)
#endregion


#region LCSS
func has_class(style_class: StringName) -> bool:
	return style_classes.has(style_class)


func is_style_state_active(state: StringName) -> bool:
	return _style != null and _style.is_state_active(state)


## Recalcula o LCSSStyle deste componente a partir da LcssRegistry
## guardada em LuaUi, e reaplica em todos os alvos registrados.
func _refresh_style() -> void:
	_style = LCSSResolver.resolve(self, LuaUi.lcss)
	_style_target.apply_style(_style, _style_overrides)


func _set_style_state(state: StringName, active: bool) -> void:
	if _style == null:
		return
	_style.set_state_active(state, active)
	_style_target.apply_style(_style, _style_overrides)


## Conecta hover/focus/pressed de um Control interno (ex: o Button real
## dentro do slot) aos estados LCSS. Chame em _component_ready() do
## componente que tiver essa superfície.
func _bind_style_state_source(source: Control) -> void:
	source.mouse_entered.connect(func(): _set_style_state(&"hover", true))
	source.mouse_exited.connect(func(): _set_style_state(&"hover", false))
	source.focus_entered.connect(func(): _set_style_state(&"focus", true))
	source.focus_exited.connect(func(): _set_style_state(&"focus", false))
	if source.has_signal("button_down"):
		source.button_down.connect(func(): _set_style_state(&"pressed", true))
		source.button_up.connect(func(): _set_style_state(&"pressed", false))
#endregion


#region Lua communication
func emit_event(event: String, args: Array = []) -> void:
	var cb: Callable = handlers.get("on_" + event, Callable())
	if cb.is_valid():
		cb.callv(args)


func call_hook(hook: String, args: Array = [], default: Variant = null) -> Variant:
	var cb: Callable = handlers.get(hook, Callable())
	if not cb.is_valid():
		return default
	var result: Variant = cb.callv(args)
	return default if result == null else result


func forward_signal(source: Signal, event: String) -> void:
	source.connect(func(...args): emit_event(event, args))


func call_exposed(method: String, args: Array = []) -> Variant:
	if method not in _schema.get("methods", []):
		push_error("[LuaComponent:%s] método '%s' não está exposto no schema" % [component_name, method])
		return null
	if not has_method(method):
		push_error("[LuaComponent:%s] método '%s' declarado mas não implementado" % [component_name, method])
		return null
	return callv(method, args)
#endregion


#region Slots
func get_slot(slot_name: String) -> Node:
	if _slot_cache.has(slot_name):
		return _slot_cache[slot_name]
	var path: String = _schema.get("slots", {}).get(slot_name, "")
	if path == "":
		return null
	var node := get_node_or_null(path)
	_slot_cache[slot_name] = node
	return node
#endregion
