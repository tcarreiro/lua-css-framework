class_name LCSSStyleSheet extends RefCounted

var rules: Array[LCSSRule] = []
var keyframes: Dictionary = {}   # nome -> LCSSKeyframes


func add_rule(rule: LCSSRule) -> void:
	rules.append(rule)


func get_rules() -> Array[LCSSRule]:
	return rules.duplicate()

func add_keyframes(anim_name: String, frames: LCSSKeyframes) -> void:
	keyframes[anim_name] = frames
