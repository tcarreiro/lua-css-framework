class_name LCSSParser extends RefCounted


func parse(text: String) -> LCSSStyleSheet:
	var ast := LCSSSyntaxParser.new().parse(text)
	var stylesheet := LCSSStyleSheet.new()

	for diagnostic: Dictionary in ast.errors:
		push_warning(
			"[LCSSParser] Line %d, column %d: %s" % [
				int(diagnostic.get("line", 1)),
				int(diagnostic.get("column", 1)),
				str(diagnostic.get("message", "Unknown parsing error"))
			]
		)

	for node: Variant in ast.nodes:
		if node is LCSSRuleNode:
			_add_rules_from_node(stylesheet, node)
		elif node is LCSSKeyframesNode:
			_add_keyframes_from_node(stylesheet, node)

	return stylesheet


func _add_rules_from_node(stylesheet: LCSSStyleSheet, node: LCSSRuleNode) -> void:
	var properties := _parse_declarations(node.declarations)

	for selector_text: String in node.selectors:
		stylesheet.add_rule(LCSSRule.new(selector_text, properties))


func _add_keyframes_from_node(stylesheet: LCSSStyleSheet, node: LCSSKeyframesNode) -> void:
	var keyframes := LCSSKeyframes.new()

	for frame: LCSSRuleNode in node.frames:
		var properties := _parse_declarations(frame.declarations)

		for selector_text: String in frame.selectors:
			var offset := _parse_keyframe_offset(selector_text)

			if offset >= 0.0:
				keyframes.add_frame(offset, properties)

	stylesheet.add_keyframes(node.animation_name, keyframes)


func _parse_declarations(declarations: Array) -> Dictionary[StringName, Variant]:
	var properties: Dictionary[StringName, Variant] = {}

	for declaration: LCSSDeclarationNode in declarations:
		var property_name := declaration.property_name.strip_edges()

		if property_name.is_empty():
			continue

		properties[StringName(property_name)] = _parse_value(
			declaration.value_text.strip_edges()
		)

	return properties


func _parse_keyframe_offset(selector: String) -> float:
	var key := selector.strip_edges()

	if key == "from":
		return 0.0

	if key == "to":
		return 1.0

	if key.ends_with("%"):
		var percentage := key.trim_suffix("%").strip_edges()

		if percentage.is_valid_float():
			return clampf(percentage.to_float() / 100.0, 0.0, 1.0)

	return -1.0


func _parse_value(value: String) -> Variant:
	if value.is_empty():
		return null

	if value.is_valid_int():
		return value.to_int()

	if value.is_valid_float():
		return value.to_float()

	if value.ends_with("ms") and value.trim_suffix("ms").is_valid_float():
		return value.trim_suffix("ms").to_float() / 1000.0

	if value.ends_with("s") and value.trim_suffix("s").is_valid_float():
		return value.trim_suffix("s").to_float()

	if value.begins_with("[") and value.ends_with("]"):
		return _parse_array(value)

	if value.ends_with(")") and value.find("(") > 0:
		return _parse_call(value)

	var tokens := value.split(" ", false)

	if tokens.size() > 1:
		var numbers: Array = []

		for token: String in tokens:
			if not (token.is_valid_int() or token.is_valid_float()):
				return value

			numbers.append(_parse_value(token))

		return numbers

	return value


func _parse_call(value: String) -> Variant:
	var open := value.find("(")
	var function_name := value.substr(0, open).strip_edges()
	var inner := value.substr(open + 1, value.length() - open - 2).strip_edges()
	var args: Array = []

	if not inner.is_empty():
		for raw: String in inner.split(","):
			args.append(_strip_quotes(raw.strip_edges()))

	match function_name:
		LCSS.TEXTURE_FN, LCSS.URL_FN:
			if args.is_empty() or str(args[0]).is_empty():
				push_warning(
					"[LCSSParser] %s() requires a non-empty path." % function_name
				)
				return null

			return args[0]

		_:
			push_warning(
				"[LCSSParser] Unknown function: '%s'." % function_name
			)
			return value


func _parse_array(value: String) -> Array:
	var content := value.substr(1, value.length() - 2).strip_edges()

	if content.is_empty():
		return []

	var result: Array = []

	for item: String in content.split(","):
		result.append(_parse_value(item.strip_edges()))

	return result


func _strip_quotes(value: String) -> String:
	if value.length() >= 2:
		if (value.begins_with('"') and value.ends_with('"')) \
		or (value.begins_with("'") and value.ends_with("'")):
			return value.substr(1, value.length() - 2)

	return value
