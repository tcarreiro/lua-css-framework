class_name LCSSStyleSheet extends RefCounted
# Cache of parsed LCSSRules and LCSSKeyFrames

var rules: Array[LCSSRule] = []
var keyframes: Dictionary[StringName, LCSSKeyframes] = {}   # name -> LCSSKeyframes


func add_rule(rule: LCSSRule) -> void:
	rules.append(rule)


func get_rules() -> Array[LCSSRule]:
	return rules.duplicate()


func add_keyframes(anim_name: String, frames: LCSSKeyframes) -> void:
	keyframes[anim_name] = frames
