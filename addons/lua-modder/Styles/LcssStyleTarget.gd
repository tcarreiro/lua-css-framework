class_name LCSSStyleTarget extends RefCounted
## Liga NOMES DE PROP (como aparecem no .lua e no .lcss, o "contexto") a um alvo do
## componente e à propriedade canônica (ComponentProps.*) que o LCSSAppliers aplica.
##
##   register_property(ComponentProps.FONT_COLOR, _label)                      # contexto = "font_color"
##   register_property(ComponentProps.FONT_COLOR, _label, &"label_font_color") # contexto explícito
##   register_group(ComponentProps.FONT, _label, "label_")                     # label_font_color, label_font_size...
##
## Famílias: o contexto é o do atalho; as partes herdam o sufixo
## (input_padding -> input_padding_left, input_padding_top, ...).

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

var _property_targets: Dictionary[StringName, Node] = {}
var _family_targets: Dictionary[StringName, Node] = {}
var _simple: Dictionary = {}     # context -> Binding
var _families: Dictionary = {}   # context -> FamilyBinding
var _contexts: Dictionary = {}   # todo contexto conhecido -> Binding | FamilyBinding


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


## Recebe o nome como escrito no .lua/.lcss (context)
func has_property(context: StringName) -> bool:
	return _contexts.has(context)


func get_properties() -> Array[StringName]:
	var properties: Array[StringName] = []
	properties.assign(_contexts.keys())
	return properties


func get_target(context: StringName) -> Node:
	var entry: Variant = _contexts.get(context)
	return entry.target if entry != null else null


func apply_style(style: LCSSStyle, overrides: Dictionary[StringName, Variant] = {}) -> void:
	# simples: inline (props do .lua) > estilo (.lcss)
	for context: StringName in _simple:
		var binding: Binding = _simple[context]
		var value: Variant = overrides[context] if overrides.has(context) else _style_value(style, context)
		if value != null:
			LCSSAppliers.apply(binding.property, value, binding.target)

	# famílias: inline > estilo; dentro de cada camada, parte > atalho
	for fb: FamilyBinding in _families.values():
		var layers: Array[Callable] = [
			func(p: StringName) -> Variant: return overrides.get(fb.context_of(p)),
			func(p: StringName) -> Variant: return _style_value(style, fb.context_of(p)),
		]
		LCSSAppliers.apply_family(fb.family, ComponentProps.resolve_family(fb.family, layers), fb.target)


func apply_property(context: StringName, value: Variant, handler: Callable) -> bool:
	var entry: Variant = _contexts.get(context)
	if entry == null:
		return false
	handler.call(context, value, entry.target)
	return true


func _style_value(style: LCSSStyle, context: StringName) -> Variant:
	if style != null and style.has_effective_property(context):
		return style.get_effective_property(context)
	return null

#func register_property(property: StringName, target: Node) -> void:
	#var family := ComponentProps.family_of(property)
	#if family != &"":
		#register_family(family, target)
		#return
	#_property_targets[property] = target
#
#
#func unregister_property(property: StringName) -> void:
	#_property_targets.erase(property)
#
#
#func register_family(family: StringName, target: Node) -> void:
	#_family_targets[family] = target
	#_property_targets[family] = target 
	#for member: StringName in ComponentProps.members_of(family):
		#_property_targets[member] = target
#
#
#func unregister_family(family: StringName) -> void:
	#_family_targets.erase(family)
	#_property_targets.erase(family)
	#for member: StringName in ComponentProps.members_of(family):
		#_property_targets.erase(member)
#
#
#func has_property(property: StringName) -> bool:
	#return _property_targets.has(property)
#
#
#func get_properties() -> Array[StringName]:
	#var properties: Array[StringName] = []
	#properties.assign(_property_targets.keys())
	#return properties
#
#
#func get_target(property: StringName) -> Node:
	#return _property_targets.get(property)
#
#
#func apply_style(style: LCSSStyle, overrides: Dictionary[StringName, Variant] = {}) -> void:
	## propriedades simples
	#for property: StringName in _property_targets:
		#if ComponentProps.family_of(property) != &"":
			#continue 
		#if overrides.has(property):
			## Override is what comes as a prop directly from the .lua file
			#LCSSAppliers.apply(property, overrides[property], _property_targets[property])
		#elif style != null and style.has_effective_property(property):
			## This is what comes from a .lcss file
			#LCSSAppliers.apply(property, style.get_effective_property(property), _property_targets[property])
#
	#var inline_layer := func(p: StringName) -> Variant:
		#return overrides.get(p)
	#var style_layer := func(p: StringName) -> Variant:
		#if style != null and style.has_effective_property(p):
			#return style.get_effective_property(p)
		#return null
	#var layers: Array[Callable] = [inline_layer, style_layer]
#
	#for family: StringName in _family_targets:
		#var values := ComponentProps.resolve_family(family, layers)
		#LCSSAppliers.apply_family(family, values, _family_targets[family])
#
#
#func apply_property(property: StringName, value: Variant, handler: Callable) -> bool:
	#if not _property_targets.has(property):
		#return false
#
	#handler.call(property, value, _property_targets[property])
	#return true
