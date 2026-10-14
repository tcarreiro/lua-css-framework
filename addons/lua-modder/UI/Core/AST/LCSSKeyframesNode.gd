@tool
class_name LCSSKeyframesNode extends LCSSSyntaxNode


var animation_name: String = ""
var frames: Array[LCSSRuleNode] = []


func get_frame(selector: String) -> LCSSRuleNode:
	for frame in frames:
		if frame.selectors.has(selector):
			return frame

	return null
