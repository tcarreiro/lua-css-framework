class_name LCSSRule extends RefCounted

var selector: LCSSSelector
var properties: Dictionary[StringName, Variant] = {}

func _init(p_selector: String = "", p_properties: Dictionary[StringName, Variant] = {}) -> void:
	selector = LCSSSelector.new()
	selector.parse(p_selector)
	properties = p_properties.duplicate()
