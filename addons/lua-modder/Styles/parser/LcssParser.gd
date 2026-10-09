class_name LcssParser extends RefCounted

const COMMENT_MARKER = "//"

func parse(text: String) -> LCSSStyleSheet:
	var stylesheet := LCSSStyleSheet.new()
	var position := 0
	var comments := []

	while position < text.length():
		var comment_start := text.find(COMMENT_MARKER, position)
		if comment_start == -1:
			break
	
		var comment_end := text.find("\n", comment_start)
		if comment_end == -1:
			comment_end = text.length()
	
		comments.append(text.substr(comment_start, comment_end - comment_start))
		position = comment_end + 1
	
	for comment in comments:
		text = text.replace(comment, "")
	
	position = 0
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

		var body := text.substr(open_brace + 1, close_brace - open_brace - 1)

		var properties := _parse_properties(body)

		stylesheet.add_rule(LCSSRule.new(selector, properties))

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

	#TBD: usar formato de css padding: 5 1 2 4, sem "[]"
	#var tokens := value.split(" ", false)
	#if tokens.size() > 1:
		#var numbers: Array = []
		#for t in tokens:
			#if not (t.is_valid_int() or t.is_valid_float()):
				#return value   # texto livre, ex.: nome de fonte
			#numbers.append(_parse_value(t))
		#return numbers
	return value


func _parse_array(value: String) -> Array:
	var content := value.substr(1, value.length() - 2).strip_edges()

	if content.is_empty():
		return []

	var result: Array = []

	for item in content.split(","):
		result.append(_parse_value(item.strip_edges()))

	return result
