class_name LCSSStyleTarget extends RefCounted
## Liga NOMES DE PROP (como aparecem no .lua e no .lcss, o "contexto") a um alvo do
## componente e à propriedade (ComponentProps.*) que o LCSSAppliers aplica, e anima as mudanças de valor.
##
##   register_property(ComponentProps.FONT_COLOR, _label)                      # contexto = "font_color"
##   register_property(ComponentProps.FONT_COLOR, _label, &"label_font_color") # contexto explícito
##   register_group(ComponentProps.FONT, _label, "label_")                     # label_font_color, label_font_size...
##
## Famílias: o contexto é o do atalho; as partes herdam o sufixo
## (input_padding -> input_padding_left, input_padding_top, ...).

enum Kind { NONE, COLOR, NUMBER, VECTOR, FAMILY }

#region Internal classes
class Binding extends RefCounted:
	var property: StringName
	var target: Node


class FamilyBinding extends RefCounted:
	var family: StringName
	var target: Node
	var shorthand: StringName
	var members: Array[StringName] = [] 

	func context_of(canonical: StringName) -> StringName:
		if canonical == family:
			return shorthand
		var i := ComponentProps.members_of(family).find(canonical)
		return members[i] if i >= 0 else &""


class Transition extends RefCounted:
	
	var duration := 0.0
	var trans: int = Tween.TRANS_QUAD
	var ease_type: int = Tween.EASE_OUT
	var loop: StringName = ComponentProps.ONE_SHOT
	var repetitions: int = -1
	var properties: Array[String] = []   # vazio = all

	func covers(key: StringName) -> bool:
		return properties.is_empty() or properties.has(ComponentProps.ALL) or properties.has(String(key))
#endregion

var _property_targets: Dictionary[StringName, Node] = {}
var _family_targets: Dictionary[StringName, Node] = {}
var _simple: Dictionary = {}     # context -> Binding
var _families: Dictionary = {}   # context -> FamilyBinding
var _contexts: Dictionary = {}   # todo contexto conhecido -> Binding | FamilyBinding
var _meta: Dictionary = {}            # chaves que só configuram (transition_*), sem alvo

var _target_values: Dictionary = {}   # chave -> último valor RESOLVIDO
var _shown: Dictionary = {}           # chave -> valor aplicado agora (muda durante o tween)
var _tweens: Dictionary = {}
var _transitions_enabled := false

#region Register
func register_property(property: StringName, target: Node, context: StringName = &"") -> void:
	if ComponentProps.FAMILIES.has(property):
		register_family(property, target, context)
		return
	var family := ComponentProps.family_of(property)
	if family != &"":
		push_warning("[LCSSStyleTarget] '%s' é parte de uma família; registre o atalho '%s'." % [property, family])
		return
	var binding := Binding.new()
	binding.property = property
	binding.target = target
	var ctx := context if context != &"" else property
	_simple[ctx] = binding
	_contexts[ctx] = binding


func register_family(family: StringName, target: Node, context: StringName = &"") -> void:
	if not ComponentProps.FAMILIES.has(family):
		push_warning("[LCSSStyleTarget] '%s' não é uma família." % family)
		return
	var fb := FamilyBinding.new()
	fb.family = family
	fb.target = target
	fb.shorthand = context if context != &"" else family
	_contexts[fb.shorthand] = fb
	for member: StringName in ComponentProps.members_of(family):
		var suffix := String(member).trim_prefix(String(family))
		var ctx := StringName(String(fb.shorthand) + suffix)
		fb.members.append(ctx)
		_contexts[ctx] = fb
	_families[fb.shorthand] = fb


## Registra vários de uma vez. prefix "label_" gera label_font_color, label_font_size...
func register_group(properties: Array, target: Node, prefix: String = "") -> void:
	for property in properties:
		var context: StringName = &""
		if prefix != "":
			context = StringName(prefix + String(property))
		register_property(property, target, context)


## transition_duration / _easing / _properties: só configuram, não têm alvo.
func register_transitions() -> void:
	for ctx in ComponentProps.TRANSITION:
		_meta[ctx] = true


## Liga as animações. O LuaComponent chama no fim do _ready (sem animação de entrada).
## Se precisar de animação de entrada, deixar um estado "invisível" no começo e transicionar
## a partir dele
func enable_transitions() -> void:
	_transitions_enabled = true


func unregister_property(context: StringName) -> void:
	_simple.erase(context)
	_contexts.erase(context)


func unregister_family(context: StringName) -> void:
	var fb: FamilyBinding = _families.get(context)
	if fb == null:
		return
	_contexts.erase(fb.shorthand)
	for m in fb.members:
		_contexts.erase(m)
	_families.erase(context)
#endregion


#region Query
## Recebe o nome como escrito no .lua/.lcss (context)
func has_property(context: StringName) -> bool:
	return _contexts.has(context) or _meta.has(context)


func get_properties() -> Array[StringName]:
	var properties: Array[StringName] = []
	properties.assign(_contexts.keys())
	properties.append_array(_meta.keys())
	return properties


func get_target(context: StringName) -> Node:
	var entry: Variant = _contexts.get(context)
	return entry.target if entry != null else null


func apply_property(context: StringName, value: Variant, handler: Callable) -> bool:
	var entry: Variant = _contexts.get(context)
	if entry == null:
		return false
	handler.call(context, value, entry.target)
	return true
#endregion


#region Application
## `animate = false` aplica direto, sem tween (usado no boot e ao re-resolver descendentes).
func apply_style(style: LCSSStyle, overrides: Dictionary[StringName, Variant] = {}, animate := true) -> void:
	var transition: Transition = _read_transition(style, overrides) if (_transitions_enabled and animate) else null
	
	# simples: inline (props do .lua) > estilo (.lcss)
	for context: StringName in _simple:
		var binding: Binding = _simple[context]
		var value: Variant = overrides[context] if overrides.has(context) else _style_value(style, context)
		_drive(context, binding.property, value, binding.target, transition, false)

	# famílias: inline > lcss; dentro de cada camada, parte > atalho
	for fb: FamilyBinding in _families.values():
		var layers: Array[Callable] = [
			func(p: StringName) -> Variant: return overrides.get(fb.context_of(p)),
			func(p: StringName) -> Variant: return _style_value(style, fb.context_of(p)),
		]
		var values := ComponentProps.resolve_family(fb.family, layers)
		_drive(fb.shorthand, fb.family, values, fb.target, transition, true)


func _drive(key: StringName, property: StringName, value: Variant, target: Node,
		transition: Transition, is_family: bool) -> void:
	if value == null:
		# propriedade simples que saiu do estilo (ex.: saiu do :hover que era o único a defini-la)
		if _target_values.has(key):
			_cancel_tween(key)
			LCSSAppliers.reset(property, target)
			_target_values.erase(key)
			_shown.erase(key)
		return

	if _target_values.has(key) and _same(_target_values[key], value):
		return   # nada mudou: não reaplica e não reinicia o tween (nem o loop)

	var had_previous := _shown.has(key)
	var from: Variant = _shown.get(key)
	_target_values[key] = _copy(value)
	_cancel_tween(key)

	if transition == null or not had_previous or not transition.covers(key):
		_commit(key, property, value, target, is_family)
		return

	var kind := _kind(property, from, value, is_family)
	if kind == Kind.NONE:
		_commit(key, property, value, target, is_family)
		return

	var a: Variant = _normalize(kind, from)
	var b: Variant = _normalize(kind, value)
	var step: Callable = func(t: float): _step(key, property, kind, a, b, t, target, is_family)
	var d := transition.duration

	var tween := target.create_tween()
	tween.set_trans(transition.trans).set_ease(transition.ease_type)
	_tweens[key] = tween

	var infinite := transition.loop != ComponentProps.ONE_SHOT and transition.repetitions < 1
	match transition.loop:
		ComponentProps.PING_PONG:
			if infinite:
				tween.tween_method(step, 0.0, 1.0, d)
				tween.tween_method(step, 1.0, 0.0, d)
				tween.set_loops()   # sem argumento = infinito
			else:
				# desenrolado: n ciclos (A→B→A) e uma ida final, para assentar no alvo
				for i in transition.repetitions:
					tween.tween_method(step, 0.0, 1.0, d)
					tween.tween_method(step, 1.0, 0.0, d)
				tween.tween_method(step, 0.0, 1.0, d)
		ComponentProps.LOOP:
			tween.tween_method(step, 0.0, 1.0, d)
			if infinite:
				tween.set_loops()
			else:
				tween.set_loops(transition.repetitions)
		_:
			tween.tween_method(step, 0.0, 1.0, d)

	if infinite:
		return   # nunca termina: nada a assentar. Quem interrompe é o próximo _drive.

	# `finished` dispara uma vez, depois de todas as voltas (e não dispara com kill()).
	tween.finished.connect(func():
		if _tweens.get(key) != tween:
			return
		_tweens.erase(key)
		_commit(key, property, value, target, is_family))


func _commit(key: StringName, property: StringName, value: Variant, target: Node, is_family: bool) -> void:
	_shown[key] = _copy(value)
	_call_applier(property, value, target, is_family)


func _step(key: StringName, property: StringName, kind: int, a: Variant, b: Variant,
		t: float, target: Node, is_family: bool) -> void:
	if not is_instance_valid(target):
		return
	var v: Variant = _lerp(kind, a, b, t)
	_shown[key] = v
	_call_applier(property, v, target, is_family)


func _call_applier(property: StringName, value: Variant, target: Node, is_family: bool) -> void:
	if is_family:
		LCSSAppliers.apply_family(property, value, target)
	else:
		LCSSAppliers.apply(property, value, target)


func _cancel_tween(key: StringName) -> void:
	var tween: Tween = _tweens.get(key)
	if tween != null and tween.is_valid():
		tween.kill()
	_tweens.erase(key)
#endregion

#region Interpolação
static func _kind(property: StringName, from: Variant, to: Variant, is_family: bool) -> int:
	if ComponentProps.SCROLLBAR.has(property):
		return Kind.NONE   # scrollbar tween is very expensive. Disabled for now
	if is_family:
		return Kind.FAMILY if (from is Array and to is Array) else Kind.NONE
	if ComponentProps.type_of(property) == TYPE_COLOR:
		return Kind.COLOR
	if _is_numeric(from) and _is_numeric(to):
		return Kind.NUMBER if (_is_number(from) and _is_number(to)) else Kind.VECTOR
	return Kind.NONE


static func _is_number(v: Variant) -> bool:
	return v is int or v is float


static func _is_numeric(v: Variant) -> bool:
	if _is_number(v):
		return true
	if v is Array and not v.is_empty():
		for item in v:
			if not _is_number(item):
				return false
		return true
	return false


static func _normalize(kind: int, v: Variant) -> Variant:
	match kind:
		Kind.COLOR: return LuaHelper.parse_color(v)
		Kind.NUMBER: return float(v)
		Kind.VECTOR: return LuaHelper.parse_distributable(v)
	return v


static func _lerp(kind: int, a: Variant, b: Variant, t: float) -> Variant:
	match kind:
		Kind.COLOR:
			var ca: Color = a
			return ca.lerp(b, t)
		Kind.NUMBER:
			return lerpf(a, b, t)
		Kind.VECTOR:
			var out: Array = []
			for i in b.size():
				out.append(lerpf(a[i], b[i], t))
			return out
		Kind.FAMILY:
			# parte indefinida de um lado conta como 0; no fim o _commit aplica o alvo exato (com nulls)
			var out: Array = []
			out.resize(b.size())
			for i in b.size():
				var ai: Variant = a[i] if i < a.size() else null
				var bi: Variant = b[i]
				if ai == null and bi == null:
					out[i] = null
				else:
					out[i] = lerpf(float(ai) if ai != null else 0.0, float(bi) if bi != null else 0.0, t)
			return out
	return b


static func _same(a: Variant, b: Variant) -> bool:
	return typeof(a) == typeof(b) and a == b


static func _copy(v: Variant) -> Variant:
	return v.duplicate() if v is Array else v
#endregion


#region Config
func _read_transition(style: LCSSStyle, overrides: Dictionary) -> Transition:
	var duration: Variant = _resolve(style, overrides, ComponentProps.TRANSITION_DURATION)
	if duration == null or float(duration) <= 0.0:
		return null
	var t := Transition.new()
	t.duration = float(duration)

	var easing: Variant = _resolve(style, overrides, ComponentProps.TRANSITION_EASING)
	if easing != null and ComponentProps.EASINGS.has(StringName(str(easing))):
		var pair: Array = ComponentProps.EASINGS[StringName(str(easing))]
		t.trans = pair[0]
		t.ease_type = pair[1]
	
	var loop: Variant = _resolve(style, overrides, ComponentProps.TRANSITION_LOOP)
	if loop != null and ComponentProps.LOOP_OPTIONS.has(StringName(str(loop))):
		t.loop = StringName(str(loop))

	var repetitions: Variant = _resolve(style, overrides, ComponentProps.TRANSITION_REPETITIONS)
	if repetitions != null:
		t.repetitions = -1 if str(repetitions) == "infinite" else int(repetitions)

	var listed: Variant = _resolve(style, overrides, ComponentProps.TRANSITION_PROPERTIES)
	if listed is Array:
		for p in listed:
			t.properties.append(str(p))
	elif listed != null:
		for p in str(listed).replace(",", " ").split(" ", false):
			t.properties.append(p)
	return t


func _resolve(style: LCSSStyle, overrides: Dictionary, context: StringName) -> Variant:
	return overrides[context] if overrides.has(context) else _style_value(style, context)


func _style_value(style: LCSSStyle, context: StringName) -> Variant:
	if style != null and style.has_effective_property(context):
		return style.get_effective_property(context)
	return null

#endregion
