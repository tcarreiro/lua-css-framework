class_name LCSSStyleSheet extends RefCounted

var rules: Array[LCSSRule] = []


func add_rule(rule: LCSSRule) -> void:
	rules.append(rule)


func get_rules() -> Array[LCSSRule]:
	return rules.duplicate()
