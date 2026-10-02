class_name LCSSResolver extends RefCounted

static func resolve(component: LuaComponent, registry: LcssRegistry) -> LCSSStyle:
	var matched: Array[LCSSRule] = []
	for sheet in registry.get_stylesheets():
		for rule in sheet.get_rules():
			if rule.selector.matches(component, false):
				matched.append(rule)

	matched.sort_custom(func(a, b): return a.selector.get_specificity() < b.selector.get_specificity())

	var style := LCSSStyle.new()
	for rule in matched:
		var state := _own_state(rule.selector)
		var target: LCSSStyle = style if state == &"" else style.ensure_state(state)
		for property: StringName in rule.properties:
			target.set_property(property, rule.properties[property])
	return style


## Estado declarado na ÚLTIMA parte do selector (":hover" em ".foo:hover").
## Suporta um só estado por regra — casa com o que já está no seu .lcss.
static func _own_state(selector: LcssSelector) -> StringName:
	if selector.parts.is_empty():
		return &""
	var last: Dictionary = selector.parts[selector.parts.size() - 1]
	var states: Array = last.get("states", [])
	return states[0] if not states.is_empty() else &""
