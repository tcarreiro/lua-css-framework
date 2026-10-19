class_name LCSSStyleClass extends RefCounted

var style_sheet: LCSSStyleSheet
var token: LCSSToken
# A StyleClass can have multiple selectors, like .main-menu.primary-button:hover {}
var selectors: Array[LCSSStyleSelector] = []
var properties: Dictionary[StringName, LCSSProperty] = {}

class LCSSStyleSelector:
	extends RefCounted
	var name: StringName
	var state: StringName
	
	func _init(_name: StringName, _state: StringName = &"") -> void:
		name = _name
		state = _state
	
	func _to_string() -> String:
		return "LCSSStyleSelector(name=%s, state=%s,)" % [name, state]


func _init(_style_sheet: LCSSStyleSheet, _token: LCSSToken) -> void:
	style_sheet = _style_sheet
	token = _token
	parse()


func parse() -> void:
	LCSSParser.parse_style_class(self)


#func set_name(new_name: StringName)-> void:
	#name = new_name
#
#
#func add_state(_state: LCSSState) -> void:
	#states[_state.name] = _state


func add_style_selector(_style_selector: LCSSStyleSelector) -> void:
	selectors.append(_style_selector)


func add_property(_property: LCSSProperty) -> void:
	properties[_property.name] = _property


func matches(component: LuaComponent, match_states: bool = true) -> bool:
	if component == null:
		return false

	var part_index := selectors.size() - 1
	var current: LuaComponent = component

	if not _matches_part(current, match_states):
		return false

	part_index -= 1

	while part_index >= 0:
		current = _find_matching_ancestor(current, match_states)

		if current == null:
			return false

		part_index -= 1

	return true


func _matches_part(component: LuaComponent, match_states: bool) -> bool:
	var classes := selectors.map(func(s: LCSSStyleSelector): return s.name)
	var states := selectors.map(func(s: LCSSStyleSelector): return s.state)
	for style_class: StringName in classes:
		if not component.has_class(style_class):
			return false

	if match_states:
		for state: StringName in states:
			if not component.is_style_state_active(state):
				return false

	return true


func _find_matching_ancestor(from_component: LuaComponent, match_states: bool) -> LuaComponent:
	var node := from_component.get_parent()

	while node != null:
		if node is LuaComponent:
			var component := node as LuaComponent

			if _matches_part(component, match_states):
				return component

		node = node.get_parent()
	return null


func get_specificity() -> int:
	var specificity := 0

	for part in selectors:
		specificity += 1 # accounting for "name"
		if part.state != &"":
			specificity += 1

	return specificity


func _to_string() -> String:
	return "LCSSStyleClass(selectors=%s, properties=%s)" % [
		selectors, properties.values()
	]
