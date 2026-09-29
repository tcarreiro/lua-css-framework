class_name LuaComponent extends Control
## Raiz obrigatória de toda cena registrada em ComponentRegistry.
##
## Como escrever um componente:
##   1. Cena com raiz Control (ou filho) + script `extends LuaComponent`.
##   2. Override `get_schema()` (contrato: props, events, hooks, methods, slots).
##   3. Override `_apply_prop(key, value)` para refletir cada prop na UI.
##   4. Use `_component_ready()` em vez de `_ready()` (o `_ready` da base é quem
##      força FULL_RECT e aplica as props).
##
## Convenções com o Lua:
##   - events : você chama `emit_event("pressed", [args])`  -> Lua `on_pressed`
##   - hooks  : você chama `call_hook("format_stat", [k, v], default)` -> Lua `format_stat`
##   - methods: o Lua chama `UI.callMethod(ref, "set_loading", {true})` (whitelist do schema)
##   - slots  : `"slots": {"actions": "%ActionsSlot"}` -> Lua `slots = { actions = {...} }`

signal prop_changed(key: String, value: Variant)
signal disposing

enum InputType {
	TEXT,
	NUMBER,
	SECRET
}

var component_name: String = ""
var props: Dictionary = {}          # String -> valor já com default + coerção
var handlers: Dictionary = {}       # "on_x" / hook -> Callable
var component_id: String = ""

## Marca se ESTE componente já recebeu a prop diretamente (não herdada do
## pai). Enquanto false, aceita herdar de um LuaComponent ancestral.
var _has_own_class := false
var _has_own_style_vars := false

var _schema: Dictionary = {}
var _is_ready := false
var _slot_cache: Dictionary = {}


#region Override points
## Contrato do componente. Deve usar apenas literais (é chamado numa instância
## "sonda" durante o boot, antes de qualquer _ready/@onready).
func get_schema() -> Dictionary:
	return {}

## Reflete UMA prop na UI. Chamado para todas no _ready e a cada set_prop().
func _apply_prop(_key: String, _value: Variant) -> void:
	pass

## Equivalente ao _ready() para as subclasses.
func _component_ready() -> void:
	pass
#endregion


#region Lifecycle
## Chamado pelo ComponentRegistry logo após instanciar, antes de entrar na árvore.
func setup(p_name: String, p_props: Dictionary, p_handlers: Dictionary, p_schema: Dictionary) -> void:
	component_name = p_name
	props = p_props
	handlers = p_handlers
	_schema = p_schema


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for key: String in props:
		_apply_prop_internal(key, props[key])
	_is_ready = true
	_component_ready()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		# solta referências para funções Lua
		handlers.clear()


## Use no lugar de queue_free() direto.
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
			var classes := LuaHelper.parse_gdss_classes(value)
			_apply_gdss(func(n): GDSSUiBridge._add_gdss_classes(n, classes), "_has_own_class")
		"style_vars":
			for var_name: String in value:
				var v: Variant = value[var_name]
				_apply_gdss(func(n): GDSSUiBridge._set_instance_var(n, StringName(var_name), v), "_has_own_style_vars")
		"visible":
			visible = value
		"tooltip":
			tooltip_text = value
		_:
			_apply_prop(key, value)
#endregion


#region Lua communication
## Dispara o evento `event` -> handler Lua `on_<event>` (se existir).
func emit_event(event: String, args: Array = []) -> void:
	var cb: Callable = handlers.get("on_" + event, Callable())
	if cb.is_valid():
		cb.callv(args)


## Chama uma função Lua que o consumidor forneceu (hook). Retorna `default` se não houver.
func call_hook(hook: String, args: Array = [], default: Variant = null) -> Variant:
	var cb: Callable = handlers.get(hook, Callable())
	if not cb.is_valid():
		return default
	var result: Variant = cb.callv(args)
	return default if result == null else result


## Repassa um sinal do Godot como evento Lua.  ex: forward_signal(%Btn.pressed, "pressed")
func forward_signal(source: Signal, event: String) -> void:
	source.connect(func(...args): emit_event(event, args))


## Método exposto ao Lua (whitelist = schema.methods).
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
## Nó (container) que hospeda o slot. null se não existir.
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


#region GDSS
## Ponto de entrada único para "class" e "style_vars": marca este componente
## como dono da prop (own_flag), aplica em toda a própria cena, e propaga
## para os LuaComponent filhos que ainda não tiverem a própria versão dela.
func _apply_gdss(apply_fn: Callable, own_flag: String) -> void:
	set(own_flag, true)
	_apply_gdss_class(apply_fn)
	_broadcast_gdss(apply_fn, own_flag)


## Aplica apply_fn a este nó e a todo Control nativo desta MESMA cena — para
## ao encontrar outro LuaComponent, que resolve a própria aparência sozinho.
func _apply_gdss_class(apply_fn: Callable) -> void:
	apply_fn.call(self)
	_apply_gdss_class_recursive(self, apply_fn)


func _apply_gdss_class_recursive(node: Node, apply_fn: Callable) -> void:
	for child in node.get_children():
		if child is LuaComponent:
			continue
		if child is Control:
			apply_fn.call(child)
		_apply_gdss_class_recursive(child, apply_fn)


## Desce a árvore procurando LuaComponent filhos. Um filho que já tem a
## própria versão de own_flag (class ou style_vars declarada nele mesmo)
## bloqueia a herança a partir dali — nem ele nem os descendentes dele
## recebem o valor do ancestral.
func _broadcast_gdss(apply_fn: Callable, own_flag: String) -> void:
	for child in get_children():
		_broadcast_gdss_to_descendant(child, apply_fn, own_flag)


func _broadcast_gdss_to_descendant(node: Node, apply_fn: Callable, own_flag: String) -> void:
	if node is LuaComponent:
		if not node.get(own_flag):
			node.set(own_flag, true)
			node._apply_gdss_class(apply_fn)
			node._broadcast_gdss(apply_fn, own_flag)
		return
	for child in node.get_children():
		_broadcast_gdss_to_descendant(child, apply_fn, own_flag)
#endregion
