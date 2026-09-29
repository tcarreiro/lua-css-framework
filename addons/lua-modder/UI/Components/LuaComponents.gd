class_name LuaComponent extends Control
## Raiz obrigatória de toda cena registrada em ComponentRegistry.
##
## Como escrever um componente:
##   1. Cena com raiz Control (ou filho) + script `extends LuaComponent`.
##   2. Override `get_schema()` (contrato: props, events, hooks, methods, slots).
##   3. Override `_apply_prop(key, value)` para refletir cada prop na UI.
##   4. Use `_component_ready()` em vez de `_ready()` (o _ready da base é quem
##      força FULL_RECT, aplica as props e inicializa o estilo).
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
var props: Dictionary = {}
var handlers: Dictionary = {}
var component_id: String = ""

var _schema: Dictionary = {}
var _is_ready := false
var _slot_cache: Dictionary = {}

var _classes: Array[StringName] = []

var _style: LCSSStyle
var _style_target: LCSSStyleTarget
var _style_overrides: Dictionary[StringName, Variant] = {}

var _style_box_cache: Dictionary[StringName, StyleBoxFlat] = {}


#region Override points

func get_schema() -> Dictionary:
	return {}


func _apply_prop(_key: String, _value: Variant) -> void:
	pass


func _setup_style_target() -> void:
	pass


func _component_ready() -> void:
	pass


func _get_style_box_default_state() -> StringName:
	return &"panel"


func _get_style_box_states() -> Dictionary[StringName, StringName]:
	return {}


func _get_style_box_target() -> Control:
	return self


func _sync_style_states() -> void:
	set_style_state(&"disabled", props.get("disabled", false))


func _apply_disabled(_value: bool) -> void:
	pass

## Control que representa a área interativa do componente.
##
## É usado para transformar eventos de entrada em estados LCSS:
##   mouse_entered -> :hover
##   mouse_exited  -> :hover
##   mouse button  -> :pressed
func _get_style_state_target() -> Control:
	return self


func _apply_lcss() -> void:
	var registry := LcssRegistry.new()
	registry.register_file("res://addons/lua-modder/Styles/global.lcss")

	var matched_rules: Array[LCSSRule] = []

	for stylesheet in registry.get_stylesheets():
		for rule in stylesheet.rules:
			if rule.selector.matches(self, false):
				matched_rules.append(rule)

	matched_rules.sort_custom(
		func(a: LCSSRule, b: LCSSRule) -> bool:
			return a.selector.get_specificity() < b.selector.get_specificity()
	)

	var style := LCSSStyle.new()

	for rule in matched_rules:
		var part: Dictionary = rule.selector.parts.back()
		var states: Array = part["states"]

		if states.is_empty():
			for property in rule.properties:
				style.set_property(property, rule.properties[property])

		elif states.size() == 1:
			var state := style.ensure_state(states[0])

			for property in rule.properties:
				state.set_property(property, rule.properties[property])

	set_style(style)

#endregion


#region Lifecycle

func setup(
	p_name: String,
	p_props: Dictionary,
	p_handlers: Dictionary,
	p_schema: Dictionary
) -> void:
	component_name = p_name
	props = p_props
	handlers = p_handlers
	_schema = p_schema


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_style_target = LCSSStyleTarget.new()
	_setup_style_target()

	for key: String in props:
		_apply_prop_internal(key, props[key])

	_is_ready = true
	_component_ready()
	_setup_style_state_input()
	_apply_lcss()
	_sync_style_states()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		handlers.clear()


func dispose() -> void:
	disposing.emit()
	handlers.clear()
	queue_free()


func _setup_style_state_input() -> void:
	var target := _get_style_state_target()

	if target == null:
		return

	target.gui_input.connect(_on_style_gui_input)


func _input(event: InputEvent) -> void:
	if not _is_ready:
		return

	if not event is InputEventMouseMotion:
		return

	var target := _get_style_state_target()

	if target == null:
		return

	var hovered := target.get_global_rect().has_point(event.position)

	set_style_state(&"hover", hovered)


func _on_style_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return

	var mouse_button := event as InputEventMouseButton

	if mouse_button.button_index != MOUSE_BUTTON_LEFT:
		return

	set_style_state(&"pressed", mouse_button.pressed)

#endregion


#region Props

func set_prop(key: String, value: Variant) -> void:
	var def: Dictionary = ComponentRegistry.get_prop_def(_schema, key)

	if def.is_empty():
		push_warning(
			"[LuaComponent:%s] prop desconhecida '%s'"
			% [component_name, key]
		)
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
			_set_classes(value)

		"visible":
			visible = value

		"tooltip":
			tooltip_text = value
		
		"disabled":
			_apply_disabled(value)
			set_style_state(&"disabled", value)

		_:
			if _style_target.has_property(key):
				if value == null:
					_style_overrides.erase(StringName(key))
				else:
					_style_overrides[StringName(key)] = value

				_apply_style()
			else:
				_apply_prop(key, value)

#endregion


#region Classes

func _set_classes(value: Variant) -> void:
	_classes.clear()

	if value is String:
		for part in value.split(" ", false):
			_classes.append(StringName(part))

	elif value is Array:
		for part in value:
			_classes.append(StringName(part))


func get_classes() -> Array[StringName]:
	return _classes.duplicate()


func has_class(style_class: StringName) -> bool:
	return _classes.has(style_class)


func add_class(style_class: StringName) -> void:
	if style_class == &"" or _classes.has(style_class):
		return

	_classes.append(style_class)


func remove_class(style_class: StringName) -> void:
	_classes.erase(style_class)

#endregion


#region Style

func set_style(style: LCSSStyle) -> void:
	if _style != null and _style.changed.is_connected(_on_style_changed):
		_style.changed.disconnect(_on_style_changed)

	_style = style

	if _style != null:
		_style.changed.connect(_on_style_changed)

	_apply_style()


func get_style() -> LCSSStyle:
	return _style


func get_style_target() -> LCSSStyleTarget:
	return _style_target


func _apply_style() -> void:
	if _style_target == null:
		return

	_style_target.apply_style(
		_style,
		_style_overrides,
		_apply_style_property
	)

	_apply_style_box_states()

func _apply_style_box_states() -> void:
	if _style == null:
		return

	var target := _get_style_box_target()

	if target == null:
		return

	var state_map := _get_style_box_states()
	var default_state := _get_style_box_default_state()

	var active_states := _style.get_active_states()

	# Pressed must override hover when both are active.
	active_states.sort_custom(
		func(a: StringName, b: StringName) -> bool:
			return _get_style_state_priority(a) < _get_style_state_priority(b)
	)

	# Always apply the base style to the default StyleBox.
	var default_style_box := _get_style_box(
		target,
		default_state
	)

	_apply_style_box_properties(
		target,
		default_style_box,
		_style
	)

	# Apply each active state to its mapped StyleBox.
	for lcss_state: StringName in active_states:
		if not _style.has_state(lcss_state):
			continue

		var state_style := _style.get_state(lcss_state)

		if state_style == null:
			continue

		var style_box_state: StringName = state_map.get(
			lcss_state,
			lcss_state
		)

		var style_box := _get_style_box(
			target,
			style_box_state
		)

		if style_box == null:
			continue

		# State StyleBoxes inherit the base style.
		_apply_style_box_properties(
			target,
			style_box,
			_style
		)

		_apply_style_box_properties(
			target,
			style_box,
			state_style
		)


func _apply_style_box_properties(
	target: Control,
	style_box: StyleBoxFlat,
	style: LCSSStyle
) -> void:
	if style_box == null or style == null:
		return

	for property: StringName in style.get_properties():
		var value: Variant = style.get_property(property)

		if _style_overrides.has(property):
			value = _style_overrides[property]

		_apply_style_property(
			property,
			value,
			target,
			style_box
		)


func _get_style_state_priority(state: StringName) -> int:
	match state:
		&"hover":
			return 10

		&"pressed":
			return 20

		&"focus":
			return 30

		&"disabled":
			return 40

		_:
			return 0


func _get_style_box(
	target: Control,
	state: StringName
) -> StyleBoxFlat:
	if _style_box_cache.has(state):
		return _style_box_cache[state]

	var style_box := target.get_theme_stylebox(state) as StyleBoxFlat

	if style_box == null:
		style_box = StyleBoxFlat.new()
	else:
		style_box = style_box.duplicate() as StyleBoxFlat

	target.add_theme_stylebox_override(state, style_box)

	_style_box_cache[state] = style_box

	return style_box


func _apply_style_property(
	property: StringName,
	value: Variant,
	target: Node,
	style_box: StyleBoxFlat = null
) -> void:
	match property:
		&"direction":
			target.vertical = (value != "row")

		&"margin":
			var margin := LuaHelper.parse_distributable(value)

			target.add_theme_constant_override("margin_left", margin[0])
			target.add_theme_constant_override("margin_top", margin[1])
			target.add_theme_constant_override("margin_right", margin[2])
			target.add_theme_constant_override("margin_bottom", margin[3])

		&"padding":
			var padding := LuaHelper.parse_distributable(value)

			target.add_theme_constant_override("margin_left", padding[0])
			target.add_theme_constant_override("margin_top", padding[1])
			target.add_theme_constant_override("margin_right", padding[2])
			target.add_theme_constant_override("margin_bottom", padding[3])

		&"background_color":
			if style_box == null:
				style_box = _get_style_box(
					target as Control,
					_get_style_box_default_state()
				)

			style_box.bg_color = LuaHelper.parse_color(value)

		&"border_color":
			if style_box == null:
				style_box = _get_style_box(
					target as Control,
					_get_style_box_default_state()
				)

			style_box.border_color = LuaHelper.parse_color(value)

		&"border_width":
			if style_box == null:
				style_box = _get_style_box(
					target as Control,
					_get_style_box_default_state()
				)

			var border := LuaHelper.parse_distributable(value)

			style_box.border_width_left = int(border[0])
			style_box.border_width_top = int(border[1])
			style_box.border_width_right = int(border[2])
			style_box.border_width_bottom = int(border[3])

		&"border_radius":
			if style_box == null:
				style_box = _get_style_box(
					target as Control,
					_get_style_box_default_state()
				)

			var radius := LuaHelper.parse_distributable(value)

			style_box.corner_radius_top_left = int(radius[0])
			style_box.corner_radius_top_right = int(radius[1])
			style_box.corner_radius_bottom_right = int(radius[2])
			style_box.corner_radius_bottom_left = int(radius[3])

		&"drop_shadow_color":
			if style_box == null:
				style_box = _get_style_box(
					target as Control,
					_get_style_box_default_state()
				)

			style_box.shadow_color = LuaHelper.parse_color(value)

		&"drop_shadow_size":
			if style_box == null:
				style_box = _get_style_box(
					target as Control,
					_get_style_box_default_state()
				)

			style_box.shadow_size = int(value)

		&"drop_shadow_offset":
			if style_box == null:
				style_box = _get_style_box(
					target as Control,
					_get_style_box_default_state()
				)

			var offset: Array = value
			style_box.shadow_offset = Vector2(offset[0], offset[1])


func _on_style_changed() -> void:
	_apply_style()


func set_style_state(state: StringName, active: bool) -> void:
	if _style == null:
		return

	_style.set_state_active(state, active)


func is_style_state_active(state: StringName) -> bool:
	if _style == null:
		return false

	return _style.is_state_active(state)

#endregion


#region Lua communication

func emit_event(event: String, args: Array = []) -> void:
	var cb: Callable = handlers.get("on_" + event, Callable())

	if cb.is_valid():
		cb.callv(args)


func call_hook(
	hook: String,
	args: Array = [],
	default: Variant = null
) -> Variant:
	var cb: Callable = handlers.get(hook, Callable())

	if not cb.is_valid():
		return default

	var result: Variant = cb.callv(args)

	return default if result == null else result


func forward_signal(source: Signal, event: String) -> void:
	source.connect(func(...args): emit_event(event, args))


func call_exposed(method: String, args: Array = []) -> Variant:
	if method not in _schema.get("methods", []):
		push_error(
			"[LuaComponent:%s] método '%s' não está exposto no schema"
			% [component_name, method]
		)
		return null

	if not has_method(method):
		push_error(
			"[LuaComponent:%s] método '%s' declarado mas não implementado"
			% [component_name, method]
		)
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
