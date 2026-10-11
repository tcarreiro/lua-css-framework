class_name LCSSResolver extends RefCounted

static func resolve(component: LuaComponent, registry: LcssRegistry) -> LCSSStyle:
	var matched: Array[Dictionary] = []   # {"rule": LCSSRule, "order": int}
	var order := 0
	for sheet in registry.get_stylesheets():
		for rule in sheet.get_rules():
			if rule.selector.matches(component, false):
				matched.append({"rule": rule, "order": order})
			order += 1

	matched.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var sa: int = (a["rule"] as LCSSRule).selector.get_specificity()
		var sb: int = (b["rule"] as LCSSRule).selector.get_specificity()
		if sa != sb:
			return sa < sb
		return int(a["order"]) < int(b["order"]))

	var style := LCSSStyle.new()
	for entry in matched:
		var rule: LCSSRule = entry["rule"]
		var state := _own_state(rule.selector)
		var target: LCSSStyle = style if state == &"" else style.ensure_state(state)
		for property: StringName in rule.properties:
			target.set_property(property, rule.properties[property])
	return style


## Estado declarado na ÚLTIMA parte do selector (":hover" em ".foo:hover").
static func _own_state(selector: LcssSelector) -> StringName:
	if selector.parts.is_empty():
		return &""
	var last: Dictionary = selector.parts[selector.parts.size() - 1]
	var states: Array = last.get("states", [])
	return states[0] if not states.is_empty() else &""
