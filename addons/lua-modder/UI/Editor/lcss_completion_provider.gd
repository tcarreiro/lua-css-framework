@tool
class_name LCSSCompletionProvider
extends Node

@export var editor: CodeEdit

const CONTEXT_SELECTOR := "selector"
const CONTEXT_PROPERTY := "property"
const CONTEXT_VALUE := "value"

const PREFIX_CLASS := LCSS.STYLE_MARKER
const PREFIX_STATE := LCSS.STATE_MARKER
const PREFIX_PROPERTY := LCSS.DECLARATION_SEPARATOR
const PREFIX_DIRECTIVE := LCSS.AT_MARKER
const PREFIX_COLOR := LCSS.COLOR_MARKER
const PROPERTY_SEPARATOR := "_"

const REGEX_CLASS_NAME := "\\.([A-Za-z_][A-Za-z0-9_-]*)"
const REGEX_STATE_NAME := ":([A-Za-z_][A-Za-z0-9_-]*)"

const DESCRIPTION_CLASS := "Classe definida neste arquivo"
const DESCRIPTION_STATE := "Pseudoestado"
const DESCRIPTION_DIRECTIVE := "Diretiva LCSS"

var _catalog: Dictionary = {}
var _completion_color := Color.WHITE
var _last_context := ""
var _last_prefix := ""


func _ready() -> void:
	if not is_instance_valid(editor):
		push_error("LCSSCompletionProvider: o CodeEdit não foi configurado.")
		return

	_catalog = LCSS._catalog()

	editor.code_completion_prefixes = [
		PROPERTY_SEPARATOR,
		PREFIX_CLASS,
		PREFIX_COLOR,
		PREFIX_STATE,
		PREFIX_PROPERTY,
		PREFIX_DIRECTIVE,
		"$",
	]

	editor.code_completion_requested.connect(_on_completion_requested)
	editor.text_changed.connect(_on_text_changed)

	_completion_color = Color.WHITE
	_request_completion()


func _exit_tree() -> void:
	if not is_instance_valid(editor):
		return

	if editor.code_completion_requested.is_connected(_on_completion_requested):
		editor.code_completion_requested.disconnect(_on_completion_requested)

	if editor.text_changed.is_connected(_on_text_changed):
		editor.text_changed.disconnect(_on_text_changed)


func _on_text_changed() -> void:
	if _caret_in_comment():
		editor.cancel_code_completion()
		return

	var context := _get_context()
	var prefix := _get_current_word()

	if context != _last_context or prefix != _last_prefix:
		_last_context = context
		_last_prefix = prefix

	_request_completion()


func _on_completion_requested() -> void:
	if _caret_in_comment():
		editor.cancel_code_completion()
		return

	_build_completions()


func _request_completion() -> void:
	if not is_instance_valid(editor):
		return

	if _caret_in_comment():
		editor.cancel_code_completion()
		return

	editor.request_code_completion(true)


func _build_completions() -> void:
	var prefix := _get_current_word()
	var context := _get_context()

	match context:
		CONTEXT_SELECTOR:
			_complete_selectors(prefix)

		CONTEXT_PROPERTY:
			_complete_properties(prefix)

		CONTEXT_VALUE:
			_complete_values(prefix)

	editor.update_code_completion_options(true)


func _complete_selectors(prefix: String) -> void:
	var selector_text := _get_current_selector_text()

	# Diretivas só aparecem quando o usuário começa a digitar "@"
	if prefix.begins_with(PREFIX_DIRECTIVE):
		var directive := LCSS.KEYFRAMES_DIRECTIVE

		if _matches_prefix(directive, prefix):
			_add_completion(
				directive,
				directive,
				DESCRIPTION_DIRECTIVE
			)
		return

	# Pseudoestados só aparecem depois de ":" em um seletor.
	if selector_text.contains(PREFIX_STATE):
		var state_prefix := prefix
		var states: Array[String] = LCSS.PSEUDO_STATES.duplicate()

		for state in _get_states_from_document():
			if not states.has(state):
				states.append(state)

		for state in states:
			if not _matches_prefix(state, state_prefix):
				continue

			_add_completion(
				PREFIX_STATE + state,
				state,
				DESCRIPTION_STATE
			)
		return

	# Classes só aparecem quando o usuário começa a digitar ".".
	if prefix.begins_with(PREFIX_CLASS):
		for classname in _get_classes_from_document():
			if not _matches_prefix(classname, prefix):
				continue

			_add_completion(
				classname,
				classname,
				DESCRIPTION_CLASS
			)


func _complete_properties(prefix: String) -> void:
	var names: Array[String] = []

	for property_name in _catalog.keys():
		names.append(str(property_name))

	for property_name in _get_custom_properties_from_document():
		if not names.has(property_name):
			names.append(property_name)

	names.sort()

	# Primeiro, tenta completar os nomes diretamente.
	for property_name in names:
		if not _matches_prefix(property_name, prefix):
			continue

		var definition := _get_property_definition(property_name)
		var description := str(definition.get(LCSS.DOC, ""))

		var display := property_name
		if not description.is_empty():
			display += "    —    " + description

		_add_completion(display, property_name, description)

	# Depois, interpreta o início como prefixo de uma propriedade composta.
	var separator_index := prefix.rfind(PROPERTY_SEPARATOR)

	if separator_index < 0:
		return

	var custom_prefix := prefix.substr(0, separator_index + 1)
	var property_prefix := prefix.substr(separator_index + 1)

	# Não sugerir todas as propriedades quando só temos "panel_".
	if property_prefix.is_empty():
		return

	for raw_property_name in _catalog.keys():
		var base_property_name := str(raw_property_name)

		if not _matches_prefix(base_property_name, property_prefix):
			continue

		var candidate := custom_prefix + base_property_name

		if names.has(candidate):
			continue

		var definition := _get_property_definition(base_property_name)
		var description := str(definition.get(LCSS.DOC, ""))

		var display := candidate
		if not description.is_empty():
			display += "    —    " + description

		_add_completion(display, candidate, description)


func _complete_values(prefix: String) -> void:
	var property_name := _get_current_property_name()

	if property_name.is_empty():
		return

	var definition := _get_property_definition(property_name)
	var options: Array = definition.get(LCSS.OPTIONS, [])

	for option in options:
		var value := str(option)

		if _matches_prefix(value, prefix):
			_add_completion(value, value, "Valor permitido")

	var property_type: int = definition.get(LCSS.TYPE, -1)
	var suggestions: Array = _get_type_suggestions(property_type)

	for suggestion in suggestions:
		var value := str(suggestion)

		if not _matches_prefix(value, prefix):
			continue

		var insert_value := value

		if (
			prefix.begins_with(PREFIX_COLOR)
			and value.begins_with(PREFIX_COLOR)
		):
			insert_value = value.substr(PREFIX_COLOR.length())

		_add_completion(
			value,
			insert_value,
			"Sugestão de valor"
		)

	# Para propriedades sem opções predefinidas, usa o valor padrão
	# como referência, desde que seja um valor simples.
	if options.is_empty():
		var default_value: Variant = definition.get(LCSS.DEFAULT)

		if default_value != null and _is_simple_value(default_value):
			var default_text := str(default_value)

			if (
				not default_text.is_empty()
				and _matches_prefix(default_text, prefix)
			):
				_add_completion(
					default_text,
					default_text,
					"Valor padrão"
				)


func _get_type_suggestions(property_type: int) -> Array:
	match property_type:
		TYPE_BOOL:
			return ["true", "false"]

		TYPE_INT:
			return ["0", "1"]

		TYPE_FLOAT:
			return ["0.0", "1.0"]

		TYPE_COLOR:
			return [
				"#FFFFFF",
				"#000000",
				"#FF0000",
				"#00FF00",
				"#0000FF",
				"transparent",
			]

	return []


func _get_property_definition(property_name: String) -> Dictionary:
	if _catalog.has(property_name):
		return _catalog[property_name]

	# Resolve nomes customizados usando o maior sufixo conhecido.
	# Ex.: header_panel_background_color.
	var candidates: Array[String] = []

	for known_name in _catalog.keys():
		var name := str(known_name)

		if property_name.ends_with(PROPERTY_SEPARATOR + name):
			candidates.append(name)

	candidates.sort_custom(
		func(a: String, b: String) -> bool:
			return a.length() > b.length()
	)

	if not candidates.is_empty():
		return _catalog[candidates[0]]

	return {}


func _get_current_property_name() -> String:
	var line := _get_current_statement()
	var colon := line.find(PREFIX_PROPERTY)

	if colon < 0:
		return ""

	return line.substr(0, colon).strip_edges()


func _get_context() -> String:
	var statement := _get_current_statement()
	var colon := statement.find(PREFIX_PROPERTY)

	if _get_brace_depth() <= 0:
		return CONTEXT_SELECTOR

	if colon >= 0:
		return CONTEXT_VALUE

	return CONTEXT_PROPERTY


func _get_current_statement() -> String:
	var caret_line := editor.get_caret_line()
	var caret_column := editor.get_caret_column()
	var line := editor.get_line(caret_line).substr(0, caret_column)

	var start := maxi(
		maxi(
			line.rfind(LCSS.BLOCK_OPEN),
			line.rfind(LCSS.BLOCK_CLOSE)
		),
		line.rfind(LCSS.DECLARATION_END)
	)

	return line.substr(start + 1).strip_edges()


func _get_brace_depth() -> int:
	var depth := 0
	var in_string := false
	var quote := ""
	var escaped := false
	var in_comment := false

	var caret_line := editor.get_caret_line()
	var caret_column := editor.get_caret_column()

	for line_index in range(caret_line + 1):
		var line := editor.get_line(line_index)
		var limit := line.length()

		if line_index == caret_line:
			limit = mini(caret_column, line.length())

		in_comment = false
		escaped = false

		for column in range(limit):
			var ch := line.substr(column, 1)
			var next_ch := ""

			if column + 1 < limit:
				next_ch = line.substr(column + 1, 1)

			if in_comment:
				break

			if in_string:
				if escaped:
					escaped = false
				elif ch == "\\":
					escaped = true
				elif ch == quote:
					in_string = false
					quote = ""
				continue

			if (
				ch == LCSS.LINE_COMMENT_START.substr(0, 1)
				and next_ch == LCSS.LINE_COMMENT_START.substr(1, 1)
			):
				in_comment = true
				break

			if (
				ch == LCSS.STRING_DOUBLE_QUOTE
				or ch == LCSS.STRING_SINGLE_QUOTE
			):
				in_string = true
				quote = ch
				continue

			if ch == LCSS.BLOCK_OPEN:
				depth += 1
			elif ch == LCSS.BLOCK_CLOSE:
				depth = maxi(0, depth - 1)

	return depth


func _get_current_word() -> String:
	var line_index := editor.get_caret_line()
	var column := editor.get_caret_column()
	var line := editor.get_line(line_index)
	var start := column

	while start > 0:
		var ch := line.substr(start - 1, 1)

		if not _is_word_character(ch):
			break

		start -= 1

	return line.substr(start, column - start)


func _is_word_character(ch: String) -> bool:
	return (
		ch >= "a" and ch <= "z"
		or ch >= "A" and ch <= "Z"
		or ch >= "0" and ch <= "9"
		or ch == PROPERTY_SEPARATOR
		or ch == "-"
		or ch == PREFIX_COLOR
		or ch == PREFIX_CLASS
		or ch == PREFIX_DIRECTIVE
		or ch == "$"
	)


func _matches_prefix(candidate: String, prefix: String) -> bool:
	if prefix.is_empty():
		return true

	return candidate.to_lower().begins_with(prefix.to_lower())


func _is_simple_value(value: Variant) -> bool:
	match typeof(value):
		TYPE_STRING, TYPE_INT, TYPE_FLOAT, TYPE_BOOL:
			return true

	return false


func _get_selectors_from_document() -> Array[String]:
	var result: Array[String] = []
	var lines := editor.text.split("\n")

	for raw_line in lines:
		var line := str(raw_line).strip_edges()

		if line.is_empty() or line.begins_with(LCSS.LINE_COMMENT_START):
			continue

		if not line.contains(LCSS.BLOCK_OPEN):
			continue

		var brace := line.find(LCSS.BLOCK_OPEN)
		var selector_text := line.substr(0, brace).strip_edges()

		if (
			selector_text.is_empty()
			or selector_text.begins_with(PREFIX_DIRECTIVE)
		):
			continue

		for raw_selector in selector_text.split(LCSS.SELECTOR_SEPARATOR):
			var selector := str(raw_selector).strip_edges()

			if selector.is_empty():
				continue

			if not result.has(selector):
				result.append(selector)

	return result


func _get_custom_properties_from_document() -> Array[String]:
	var result: Array[String] = []
	var lines := editor.text.split("\n")

	for raw_line in lines:
		var line := str(raw_line).strip_edges()
		var colon := line.find(PREFIX_PROPERTY)

		if colon <= 0:
			continue

		var name := line.substr(0, colon).strip_edges()

		if name.is_empty() or _catalog.has(name):
			continue

		if _get_property_definition(name).is_empty():
			continue

		if not result.has(name):
			result.append(name)

	return result


func _get_classes_from_document() -> Array[String]:
	var result: Array[String] = []
	var regex := RegEx.new()
	regex.compile(REGEX_CLASS_NAME)

	for selector in _get_selectors_from_document():
		for match_result in regex.search_all(selector):
			var matched_class_name: String = match_result.get_string(1)
			var candidate := PREFIX_CLASS + matched_class_name

			if not result.has(candidate):
				result.append(candidate)

	return result


func _get_states_from_document() -> Array[String]:
	var result: Array[String] = []
	var regex := RegEx.new()
	regex.compile(REGEX_STATE_NAME)

	for selector in _get_selectors_from_document():
		for match_result in regex.search_all(selector):
			var state_name: String = match_result.get_string(1)

			if not result.has(state_name):
				result.append(state_name)

	return result


func _get_text_before_caret() -> String:
	var lines := PackedStringArray()

	for line_index in range(editor.get_caret_line()):
		lines.append(editor.get_line(line_index))

	var current_line := editor.get_line(editor.get_caret_line())
	lines.append(current_line.substr(0, editor.get_caret_column()))

	return "\n".join(lines)


func _get_current_selector_text() -> String:
	var text_before_caret := _get_text_before_caret()
	var start := maxi(
		text_before_caret.rfind(LCSS.BLOCK_OPEN),
		text_before_caret.rfind(LCSS.BLOCK_CLOSE)
	)

	return text_before_caret.substr(start + 1).strip_edges()


func _caret_in_comment() -> bool:
	var caret_line := editor.get_caret_line()
	var caret_column := editor.get_caret_column()
	var line := editor.get_line(caret_line).substr(0, caret_column)

	var in_string := false
	var quote := ""
	var escaped := false

	for column in range(line.length()):
		var ch := line.substr(column, 1)
		var next_ch := ""

		if column + 1 < line.length():
			next_ch = line.substr(column + 1, 1)

		if in_string:
			if escaped:
				escaped = false
			elif ch == "\\":
				escaped = true
			elif ch == quote:
				in_string = false
				quote = ""
			continue

		if (
			ch == LCSS.STRING_DOUBLE_QUOTE
			or ch == LCSS.STRING_SINGLE_QUOTE
		):
			in_string = true
			quote = ch
			continue

		if (
			ch == LCSS.LINE_COMMENT_START.substr(0, 1)
			and next_ch == LCSS.LINE_COMMENT_START.substr(1, 1)
		):
			return true

	return false


func _add_completion(
	display: String,
	insert_text: String,
	description: String = ""
) -> void:
	editor.add_code_completion_option(
		CodeEdit.KIND_PLAIN_TEXT,
		display,
		insert_text,
		_completion_color,
		null,
		description
	)
