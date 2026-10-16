class_name LCSSRule extends RefCounted

var selector: LCSSSelector
var properties: Dictionary[StringName, LCSSProperty] = {}

func _init(p_selector: String = "", p_properties: Dictionary[StringName, LCSSProperty] = {}) -> void:
	selector = LCSSSelector.new()
	selector.parse(p_selector)
	properties = p_properties.duplicate()
