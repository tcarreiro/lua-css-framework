class_name LCSSStyle extends RefCounted

signal changed

const STATE_HOVER := &"hover"
const STATE_PRESSED := &"pressed"
const STATE_FOCUS := &"focus"
const STATE_DISABLED := &"disabled"

const _STATE_PRIORITY: Array[StringName] = [STATE_DISABLED, STATE_PRESSED, STATE_HOVER, STATE_FOCUS]

var _properties: Dictionary[StringName, Variant] = {}
var _states: Dictionary[StringName, LCSSStyle] = {}
var _active_states: Array[StringName] = []

## Protótipo (resolvido e CACHEADO) de que esta instância veio; null = estilo próprio. Duas instâncias com o
## mesmo `proto` têm exatamente as mesmas propriedades: serve para saber se reaplicar o estilo mudaria algo.
var proto: LCSSStyle
var _shared := false


## Instância leve de um estilo resolvido: compartilha as propriedades e os estados do protótipo (que nunca são
## alterados depois de cacheados) e tem só os estados ATIVOS próprios (hover, pressed...). Qualquer mutação
## copia antes (copy-on-write), então mexer numa instância jamais corrompe o cache.
static func instance_of(prototype: LCSSStyle) -> LCSSStyle:
	var style := LCSSStyle.new()
	style._properties = prototype._properties
	style._states = prototype._states
	style._shared = true
	style.proto = prototype
	return style


func _unshare() -> void:
	if not _shared:
		return
	_shared = false
	proto = null
	_properties = _properties.duplicate()
	var own: Dictionary[StringName, LCSSStyle] = {}
	for state in _states:
		var state_style := _states[state]
		if state_style == null:
			own[state] = null
			continue
		var copied := state_style.copy()
		copied.changed.connect(_on_state_changed)
		own[state] = copied
	_states = own


func set_property(property: StringName, value: Variant) -> void:
	if _properties.get(property) == value:
		return

	_unshare()
	_properties[property] = value
	changed.emit()


func remove_property(property: StringName) -> void:
	if not _properties.has(property):
		return

	_unshare()
	_properties.erase(property)
	changed.emit()


func has_property(property: StringName) -> bool:
	return _properties.has(property)


func get_property(property: StringName, default: Variant = null) -> Variant:
	return _properties.get(property, default)


func get_properties() -> Dictionary[StringName, Variant]:
	return _properties.duplicate()


func ensure_state(state: StringName) -> LCSSStyle:
	_unshare()   # devolve um estilo que o chamador pode alterar
	if not _states.has(state):
		var style := LCSSStyle.new()
		style.changed.connect(_on_state_changed)
		_states[state] = style

	return _states[state]


func set_state_style(state: StringName, style: LCSSStyle) -> void:
	if _states.get(state) == style:
		return

	_unshare()
	if _states.has(state):
		var previous := _states[state]

		if previous != null and previous.changed.is_connected(_on_state_changed):
			previous.changed.disconnect(_on_state_changed)

	_states[state] = style

	if style != null:
		style.changed.connect(_on_state_changed)

	changed.emit()


func has_state(state: StringName) -> bool:
	return _states.has(state)


## Para alterar o estado: desprende a instância do protótipo compartilhado antes (copy-on-write).
func get_state(state: StringName) -> LCSSStyle:
	_unshare()
	return _states.get(state)


## Só para LER o estado, sem desprender do protótipo. NÃO altere o que devolve: pode ser compartilhado.
func peek_state(state: StringName) -> LCSSStyle:
	return _states.get(state)


func get_states() -> Array[StringName]:
	var states: Array[StringName] = []
	states.assign(_states.keys())
	return states


func remove_state(state: StringName) -> void:
	if not _states.has(state):
		return

	_unshare()
	var style := _states[state]

	if style != null and style.changed.is_connected(_on_state_changed):
		style.changed.disconnect(_on_state_changed)

	_states.erase(state)
	changed.emit()


func set_state_active(state: StringName, active: bool) -> void:
	if active:
		if _active_states.has(state):
			return

		_active_states.append(state)
	else:
		if not _active_states.has(state):
			return

		_active_states.erase(state)

	changed.emit()


func is_state_active(state: StringName) -> bool:
	return _active_states.has(state)


func get_active_states() -> Array[StringName]:
	return _active_states.duplicate()


func clear_active_states() -> void:
	if _active_states.is_empty():
		return

	_active_states.clear()
	changed.emit()


func has_effective_property(property: StringName) -> bool:
	if _active_states.is_empty():
		return _properties.has(property)
	
	if _properties.has(property):
		return true

	for state in _active_states:
		var state_style := _states.get(state)

		if state_style != null and state_style.has_effective_property(property):
			return true

	return false


func get_effective_property(property: StringName, default: Variant = null) -> Variant:
	if _active_states.is_empty():
		return _properties.get(property, default)
	
	for state in _STATE_PRIORITY:
		if _active_states.has(state):
			var state_style := _states.get(state)
			if state_style != null and state_style.has_effective_property(property):
				return state_style.get_effective_property(property)

	# estados customizados (fora da lista fixa) continuam na ordem de ativação
	for state in _active_states:
		if state in _STATE_PRIORITY:
			continue
		var state_style := _states.get(state)
		if state_style != null and state_style.has_effective_property(property):
			return state_style.get_effective_property(property)

	return _properties.get(property, default)


func copy() -> LCSSStyle:
	var result := LCSSStyle.new()

	for property in _properties:
		result._properties[property] = _properties[property]

	for state in _states:
		if _states[state] == null:
			result._states[state] = null
			continue

		result._states[state] = _states[state].copy()
		result._states[state].changed.connect(result._on_state_changed)

	result._active_states.assign(_active_states)

	return result


func _on_state_changed() -> void:
	changed.emit()
