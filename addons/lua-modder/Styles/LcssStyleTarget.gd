class_name LCSSStyleTarget
extends RefCounted

var _property_targets: Dictionary[StringName, Node] = {}


func register_property(property: StringName, target: Node) -> void:
	_property_targets[property] = target


func unregister_property(property: StringName) -> void:
	_property_targets.erase(property)


func has_property(property: StringName) -> bool:
	return _property_targets.has(property)


func get_properties() -> Array[StringName]:
	var properties: Array[StringName] = []
	properties.assign(_property_targets.keys())
	return properties


func get_target(property: StringName) -> Node:
	return _property_targets.get(property)


func apply_style(style: LCSSStyle, overrides: Dictionary[StringName, Variant] = {}) -> void:
	for property: StringName in _property_targets:
		if overrides.has(property):
			LCSSAppliers.apply(property, overrides[property], _property_targets[property])
		elif style != null and style.has_effective_property(property):
			LCSSAppliers.apply(property, style.get_effective_property(property), _property_targets[property])


func apply_property(property: StringName, value: Variant, handler: Callable) -> bool:
	if not _property_targets.has(property):
		return false

	handler.call(property, value, _property_targets[property])
	return true
