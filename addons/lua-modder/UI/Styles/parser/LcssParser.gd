class_name LCSSParser extends RefCounted


static func _append_comments_to_style_sheet(stylesheet: LCSSStyleSheet, text: String, position: int) -> void:
	for comment in _find_comments_in_style_sheet(stylesheet, text, position, LCSS.MULTI_LINE_COMMENT_OPENER, LCSS.MULTI_LINE_COMMENT_CLOSER, false):
		stylesheet.add_comment(comment)
	for comment in _find_comments_in_style_sheet(stylesheet, text, position, LCSS.SINGLE_LINE_COMMENT):
		stylesheet.add_comment(comment)


static func _find_comments_in_style_sheet(stylesheet: LCSSStyleSheet, text: String, position: int, comment_start_marker: String,
		comment_closer_marker: String = "\n", check_if_inside_comment: bool = true) -> Array:
	var comments := []
	
	while position < text.length():
		var comment_start := text.find(comment_start_marker, position)
		if comment_start == -1:
			break
		if check_if_inside_comment:
			var end_of_comment := _get_comment_end_position(stylesheet, comment_start)
			if end_of_comment >= 0:
				position = end_of_comment+1
				continue
		var comment_end := text.find(comment_closer_marker, comment_start)
		var offset := comment_closer_marker.length()-1
		comment_end += offset
		if comment_end == offset-1:
			comment_end = text.length()

		var value := text.substr(comment_start, comment_end - comment_start + offset)
		var token := LCSSToken.new(LCSS.COMMENT, comment_start, comment_end, value)
		comments.append(token)
		position = comment_end + 1
	return comments


static func _get_comment_end_position(stylesheet: LCSSStyleSheet, position: int) -> int:
	for comment in stylesheet.get_comments():
		if position >= comment.start_position and position <= comment.end_position:
			return comment.end_position
	return -1


static func _sort_next_valid_selector(text: String, position: int) -> Dictionary:
	var start_keyframe := text.find(LCSS.KEYFRAMES_OPENER, position)
	var start_style_class := text.find(LCSS.STYLE_CLASS_OPENER, position)
	var ordering = {
		start_keyframe: LCSS.KEYFRAMES_OPENER,
		start_style_class: LCSS.STYLE_CLASS_OPENER,
	}
	ordering.sort()
	var cleared = ordering.keys().filter(func(pos): return pos > -1)
	return { "position": cleared[0], "type":ordering[cleared[0]]}


static func parse(text: String) -> LCSSStyleSheet:
	var stylesheet := LCSSStyleSheet.new()
	var position := 0
	
	_append_comments_to_style_sheet(stylesheet, text, position)
	
	while position < text.length():
		var end_of_comment := _get_comment_end_position(stylesheet, position)
		if end_of_comment > -1:
			position = end_of_comment + 1
			continue
			
		var open_brace := text.find(LCSS.BRACKET_OPENER, position)
		if open_brace == -1:
			break
		
		# Check if inside a comment
		end_of_comment = _get_comment_end_position(stylesheet, open_brace)
		if end_of_comment >= 0:
			position = end_of_comment + 1
			continue
	
		var selector := text.substr(position, open_brace - position + LCSS.BRACKET_CLOSER.length()).strip_edges()

		if selector.is_empty():
			position = open_brace + 1
			continue
		
		var next_valid_selector = _sort_next_valid_selector(text, position)
		match next_valid_selector["type"]:
			LCSS.KEYFRAMES_OPENER:
				var matching := _find_matching_brace(stylesheet, text, open_brace)
				if matching == -1:
					push_error("[LCSSParser] Unclosed @keyframes at position %s"%[open_brace])
					break
				var val = text.substr(next_valid_selector["position"], matching - next_valid_selector["position"] + LCSS.BRACKET_CLOSER.length())
				var token := LCSSToken.new(LCSS.KEYFRAMES, open_brace, matching, val)
				var keyframes := LCSSKeyframes.new(stylesheet, token)
				stylesheet.add_keyframes("kf_%s"%str(next_valid_selector["position"]), keyframes)
				position = matching + 1
				continue
			LCSS.STYLE_CLASS_OPENER:
				var matching := _find_matching_brace(stylesheet, text, open_brace)
				if matching == -1:
					push_error("[LCSSParser] Unclosed Style Class at position %s"%[open_brace])
					break
				
				var val = text.substr(next_valid_selector["position"], matching - next_valid_selector["position"] + LCSS.BRACKET_CLOSER.length())
				var token := LCSSToken.new(LCSS.STYLE_CLASS, open_brace, matching, val)
				var style_class := LCSSStyleClass.new(stylesheet, token)
				stylesheet.add_style_class(style_class)
				
				#var end_position := matching
				#var state_marker := text.find(LCSS.STATE_OPENER, next_valid_selector["position"])
				#if next_valid_selector["position"] != -1:
					#var state := text.substr(state_marker, open_brace - state_marker).strip_edges()
					#var token := LCSSToken.new(LCSS.STATE, state_marker, open_brace, state)
				#var token := LCSSToken.new(LCSS.STYLE_CLASS, open_brace, matching, selector)
				#var anim_name := selector.trim_prefix(LCSS.KEYFRAMES_OPENER).strip_edges()
				#stylesheet.add_keyframes(anim_name, _parse_keyframes(text.substr(open_brace + 1, matching - open_brace - 1)))
				position = matching + 1
				continue
		
		#if selector.begins_with(LCSS.STYLE_CLASS_OPENER):
			#var start_position := text.find(LCSS.STYLE_CLASS_OPENER, position)
			#var matching := _find_matching_brace(text, open_brace)
			#if matching == -1:
				#push_error("[LCSSParser] Unclosed Style Class at position %s"%[open_brace])
				#break
			#
			#var token := LCSSToken.new(LCSS.STYLE_CLASS, open_brace, matching, selector)
			#var style_class := LCSSStyleClass.new(token)
			#stylesheet.add_style_class(style_class)
			#
			##var end_position := matching
			##var state_marker := text.find(LCSS.STATE_OPENER, start_position)
			##if start_position != -1:
				##var state := text.substr(state_marker, open_brace - state_marker).strip_edges()
				##var token := LCSSToken.new(LCSS.STATE, state_marker, open_brace, state)
			##var token := LCSSToken.new(LCSS.STYLE_CLASS, open_brace, matching, selector)
			##var anim_name := selector.trim_prefix(LCSS.KEYFRAMES_OPENER).strip_edges()
			##stylesheet.add_keyframes(anim_name, _parse_keyframes(text.substr(open_brace + 1, matching - open_brace - 1)))
			#position = matching + 1
			#continue

		#if selector.begins_with(LCSS.KEYFRAMES_OPENER):
			#var matching := _find_matching_brace(text, open_brace)
			#if matching == -1:
				#push_error("[LCSSParser] Unclosed @keyframes at position %s"%[open_brace])
				#break
			#var anim_name := selector.trim_prefix(LCSS.KEYFRAMES_OPENER).strip_edges()
			#stylesheet.add_keyframes(anim_name, _parse_keyframes(text.substr(open_brace + 1, matching - open_brace - 1)))
			#position = matching + 1
			#continue
		#var close_brace := text.find(LCSS.BRACKET_CLOSER, open_brace + 1)
		#if close_brace == -1:
			#push_error("[LCSSParser] bloco não fechado para selector '%s'" % selector)
			#break
		#var body := text.substr(open_brace + 1, close_brace - open_brace - 1)
		#var properties := _parse_properties(body)
		#stylesheet.add_rule(LCSSRule.new(selector, properties))
		
		var close_brace := _find_matching_brace(stylesheet, text, open_brace)
		if close_brace == -1:
			push_error("[LCSSParser] Invalid brace not closed at '%s'" % open_brace)
			break
		position = close_brace + 1

	return stylesheet


static func _find_matching_brace(stylesheet: LCSSStyleSheet, text: String, open_brace: int, check_inside_comment: bool = true) -> int:
	var depth := 0
	for i in range(open_brace, text.length()):
		if check_inside_comment:
			var end_of_comment := _get_comment_end_position(stylesheet, open_brace)
			if end_of_comment >= 0:
				i = end_of_comment + 1
		match text[i]:
			LCSS.BRACKET_OPENER:
				depth += 1
			LCSS.BRACKET_CLOSER:
				depth -= 1
				if depth == 0:
					return i
	return -1


static func parse_keyframes(keyframe: LCSSKeyframes) -> LCSSKeyframes:
	var body := keyframe.token.value
	var pos := 0
	
	var first_brace := body.find(LCSS.BRACKET_OPENER, pos)
	if first_brace == -1:
		push_error("[LCSSKeyframes] Invalid format")
		return
	keyframe.name = body.substr(0, first_brace).replace(LCSS.KEYFRAMES_OPENER, "").strip_edges()
	pos = first_brace + LCSS.BRACKET_OPENER.length()
	while pos < body.length():
		var open := body.find(LCSS.BRACKET_OPENER, pos)
		if open == -1:
			break
		var close :=  _find_matching_brace(keyframe.style_sheet, body, open, false)
		if close == -1:
			break
		
		var props := parse_properties(body.substr(open+1, close - open-1))
		for raw in body.substr(pos, open - pos).split(",", false):
			var key = raw.strip_edges()
			var offset := -1.0
			if key == LCSS.FROM:
				offset = 0.0
			elif key == LCSS.TO:
				offset = 1.0
			# check if is percentage
			elif key.ends_with("%") and key.trim_suffix("%").is_valid_float():
				offset = clampf(key.trim_suffix("%").to_float() / 100.0, 0.0, 1.0)
			if offset >= 0.0:
				keyframe.add_frame(offset, props)
		pos = close + 1
	
	return keyframe


static func _split_style_classes(token: LCSSToken) -> Array[StringName]:
	var found_classes: Array[StringName] = []
	var body := token.value
	var first_brace := body.find(LCSS.BRACKET_OPENER, 0)
	if first_brace == -1:
		push_error("[LCSSStyleClass] Invalid format")
		return []
	found_classes.append_array(body.substr(0, first_brace).strip_edges().split(LCSS.STYLE_CLASS_OPENER, false))
	return found_classes


static func parse_style_class(style_class: LCSSStyleClass) -> LCSSStyleClass:
	var body := style_class.token.value
	var pos := 0
	
	var found_style_classes: Array[StringName] = _split_style_classes(style_class.token)
	for found_style_class in found_style_classes:
		_parse_style_class_name_and_state(style_class, found_style_class)
	
	while pos < body.length():
		var open := body.find(LCSS.BRACKET_OPENER, pos)
		if open == -1:
			break
		var close :=  _find_matching_brace(style_class.style_sheet, body, open, false)
		if close == -1:
			break
		
		var props := body.substr(open + 1, close - open - 1)
		var properties := parse_properties(props)
		
		for property: LCSSProperty in properties.values():
			style_class.add_property(property)
		pos = close + 1
	
	return style_class


static func _parse_style_class_name_and_state(style_class: LCSSStyleClass, style_selector_name: StringName) -> void:
	var selector_parts = style_selector_name.replace(LCSS.STYLE_CLASS_OPENER, "").strip_edges().split(LCSS.STATE_OPENER)
	var style_selector: LCSSStyleClass.LCSSStyleSelector = null
	match selector_parts.size():
		1:
			style_selector = LCSSStyleClass.LCSSStyleSelector.new(selector_parts[0])
		2:
			style_selector = LCSSStyleClass.LCSSStyleSelector.new(selector_parts[0], LCSSState.new(selector_parts[1]))
		_:
			push_error("[LCSSStyleClass] Invalid format")
			return
	if style_selector:
		style_class.add_style_selector(style_selector)


static func parse_properties(body: String) -> Dictionary[StringName, LCSSProperty]:
	var properties: Dictionary[StringName, LCSSProperty] = {}
	
	for declaration in body.split(LCSS.PROPERTY_CLOSER):
		declaration = declaration.strip_edges()

		if declaration.is_empty():
			continue

		var separator := declaration.find(LCSS.PROPERTY_SEPARATOR)

		if separator == -1:
			push_warning(
				"[LCSSParser] declaração sem ':' ignorada: '%s'"
				% declaration
			)
			continue

		var name := declaration.substr(0, separator).strip_edges()
		var raw_value := declaration.substr(separator + 1).strip_edges()

		if name.is_empty():
			continue
		properties[StringName(name)] = LCSSProperty.new(name, parse_value(raw_value))
	return properties


static func parse_value(value: String) -> Variant:
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
	var tokens := value.split(" ", false)   # "5 4" / "5 2 1 3"
	if tokens.size() > 1:
		var numbers: Array = []
		for t in tokens:
			if not (t.is_valid_int() or t.is_valid_float()):
				return value
			numbers.append(parse_value(t))
		return numbers
	return value


## Tabela de funções. Hoje só devolve valores simples; novas funções entram no match.
static func _parse_call(value: String) -> Variant:
	var open := value.find("(")
	var fn_name := value.substr(0, open).strip_edges()
	var inner := value.substr(open + 1, value.length() - open - 2).strip_edges()
	var args: Array = []
	for raw in inner.split(","):
		args.append(_strip_quotes(raw.strip_edges()))

	match fn_name:
		ComponentProps.TEXTURE_FN, ComponentProps.URL_FN:
			if args.is_empty() or str(args[0]) == "":
				push_warning("[LCSSParser] %s() sem caminho" % fn_name)
				return null
			return args[0]
		_:
			push_warning("[LCSSParser] função desconhecida: '%s'" % fn_name)
			return value


static func _strip_quotes(s: String) -> String:
	if s.length() >= 2 and (s[0] == '"' or s[0] == "'") and s[s.length() - 1] == s[0]:
		return s.substr(1, s.length() - 2)
	return s


static func _parse_array(value: String) -> Array:
	var content := value.substr(1, value.length() - 2).strip_edges()

	if content.is_empty():
		return []

	var result: Array = []

	for item in content.split(","):
		result.append(parse_value(item.strip_edges()))

	return result
