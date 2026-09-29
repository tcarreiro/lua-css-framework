class_name LcssParser extends RefCounted


func parse(text: String) -> LCSSStyleSheet:
	var stylesheet := LCSSStyleSheet.new()
	var position := 0

	while position < text.length():
		var open_brace := text.find("{", position)

		if open_brace == -1:
			break

		var selector := text.substr(position, open_brace - position).strip_edges()

		if selector.is_empty():
			position = open_brace + 1
			continue

		var close_brace := text.find("}", open_brace + 1)

		if close_brace == -1:
			push_error("[LcssParser] bloco não fechado para selector '%s'" % selector)
			break

		var body := text.substr(
			open_brace + 1,
			close_brace - open_brace - 1
		)

		var properties := _parse_properties(body)

		stylesheet.add_rule(
			LCSSRule.new(selector, properties)
		)

		position = close_brace + 1

	return stylesheet


func _parse_properties(body: String) -> Dictionary[StringName, Variant]:
	var properties: Dictionary[StringName, Variant] = {}

	for declaration in body.split(";"):
		declaration = declaration.strip_edges()

		if declaration.is_empty():
			continue

		var separator := declaration.find(":")

		if separator == -1:
			push_warning(
				"[LcssParser] declaração sem ':' ignorada: '%s'"
				% declaration
			)
			continue

		var property := declaration.substr(0, separator).strip_edges()
		var raw_value := declaration.substr(separator + 1).strip_edges()

		if property.is_empty():
			continue

		properties[StringName(property)] = _parse_value(raw_value)

	return properties


func _parse_value(value: String) -> Variant:
	if value.is_empty():
		return null

	if value.is_valid_int():
		return value.to_int()

	if value.is_valid_float():
		return value.to_float()

	if value.begins_with("[") and value.ends_with("]"):
		return _parse_array(value)

	return value


func _parse_array(value: String) -> Array:
	var content := value.substr(1, value.length() - 2).strip_edges()

	if content.is_empty():
		return []

	var result: Array = []

	for item in content.split(","):
		result.append(_parse_value(item.strip_edges()))

	return result
