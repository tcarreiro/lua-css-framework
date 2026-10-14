@tool
class_name LCSSStyleSheetNode extends LCSSSyntaxNode


var nodes: Array[LCSSSyntaxNode] = []
var errors: Array[Dictionary] = []


func get_rules() -> Array[LCSSRuleNode]:
	var result: Array[LCSSRuleNode] = []

	for node in nodes:
		if node is LCSSRuleNode:
			result.append(node)

	return result


func get_keyframes() -> Array[LCSSKeyframesNode]:
	var result: Array[LCSSKeyframesNode] = []

	for node in nodes:
		if node is LCSSKeyframesNode:
			result.append(node)

	return result
