class_name LCSSSelector extends RefCounted
# Each style "class", and states (hover, pressed etc)

var parts: Array[Dictionary] = []

func parse(selector: String) -> void:
	parts.clear()

	var result := LCSSSelectorSyntax.new().parse(selector)
	var error: Dictionary = result["error"]

	if not error.is_empty():
		push_warning("[LCSSSelector] Invalid selector '%s': %s" % [selector, error["message"]])
		return

	for part: Dictionary in result["parts"]:
		parts.append(part)


func matches(component: LuaComponent, match_states: bool = true) -> bool:
	if component == null or parts.is_empty():
		return false

	var part_index := parts.size() - 1
	var current: LuaComponent = component

	if not _matches_part(parts[part_index], current, match_states):
		return false

	part_index -= 1

	while part_index >= 0:
		current = _find_matching_ancestor(parts[part_index], current, match_states)
		if current == null:
			return false

		part_index -= 1

	return true


func _find_matching_ancestor(part: Dictionary, from_component: LuaComponent, match_states: bool) -> LuaComponent:
	var node := from_component.get_parent()

	while node != null:
		if node is LuaComponent:
			var component := node as LuaComponent

			if _matches_part(part, component, match_states):
				return component

		node = node.get_parent()

	return null


func _matches_part(part: Dictionary, component: LuaComponent, match_states: bool) -> bool:
	for style_class: StringName in part["classes"]:
		if not component.has_class(style_class):
			return false

	if match_states:
		for state: StringName in part["states"]:
			if not component.is_style_state_active(state):
				return false

	return true


func get_specificity() -> int:
	var specificity := 0

	for part in parts:
		specificity += part["classes"].size()
		specificity += part["states"].size()

	return specificity
