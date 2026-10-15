@tool
class_name LCSSHighlightProvider
extends Node

@export var editor: CodeEdit

var _highlighter: LCSSCodeHighlighter

func _ready() -> void:
	if not is_instance_valid(editor):
		push_error("LCSSHighlightProvider: o editor não foi definido.")
		return

	_highlighter = LCSSCodeHighlighter.new()
	_highlighter.refresh_catalog()

	editor.syntax_highlighter = _highlighter
	editor.text_changed.connect(_on_text_changed)

	_refresh()


func _exit_tree() -> void:
	if is_instance_valid(editor):
		if editor.text_changed.is_connected(_on_text_changed):
			editor.text_changed.disconnect(_on_text_changed)

		if editor.syntax_highlighter == _highlighter:
			editor.syntax_highlighter = null


func _on_text_changed() -> void:
	_refresh()


func _refresh() -> void:
	if not is_instance_valid(editor) or _highlighter == null:
		return

	_highlighter.set_source(editor.text)
	_highlighter.clear_highlighting_cache()
	editor.queue_redraw()


class LCSSCodeHighlighter extends SyntaxHighlighter:
	const COLOR_DEFAULT := Color.WHITE
	const COLOR_SELECTOR := Color("#80CBC4")
	const COLOR_STATE := Color("#FF731E")
	const COLOR_KEYFRAMES := Color("#CE93D8")
	const COLOR_PROPERTY := Color("#90CAF9")
	const COLOR_FUNCTION := Color("#FFCC80")
	const COLOR_NUMBER := Color("#F48FB1")
	const COLOR_STRING := Color("#A5D6A7")
	const COLOR_COMMENT := Color("#78909C")
	const COLOR_COLOR := Color("#EF9A9A")
	const COLOR_KEYWORD := Color("#CE93D8")
	const COLOR_ERROR := Color("#FF5252")

	var _source := ""
	var _tokens: Array[LCSSToken] = []
	var _properties: Dictionary = {}
	var _values: Dictionary = {}
	var _error_lines: Dictionary = {}

	func refresh_catalog() -> void:
		_properties.clear()
		_values.clear()

		var catalog: Dictionary = LCSS._catalog()

		for key: Variant in catalog:
			_properties[str(key)] = true

			var definition: Dictionary = catalog[key]
			var options: Array = definition.get(LCSS.OPTIONS, [])

			for option: Variant in options:
				_values[str(option)] = true

		for key: Variant in LCSS.BASE:
			_properties[str(key)] = true

	func set_source(source: String) -> void:
		_source = source

		var lexer := LCSSLexer.new()
		_tokens = lexer.tokenize(source)

		_error_lines.clear()

		var parser := LCSSSyntaxParser.new()
		var stylesheet: LCSSStyleSheetNode = parser.parse(source)

		_register_errors(parser.errors)
		_register_errors(stylesheet.errors)


	func _register_errors(errors: Array) -> void:
		for error: Dictionary in errors:
			var line: int = int(error.get("line", 0))

			if line > 0:
				_error_lines[line - 1] = true

	func _get_line_syntax_highlighting(line: int) -> Dictionary:
		var text_edit := get_text_edit()

		if not is_instance_valid(text_edit):
			return {}

		if line < 0 or line >= text_edit.get_line_count():
			return {}

		var line_text := text_edit.get_line(line)
		var colors: Array[Color] = []
		
		if _error_lines.has(line):
			var error_colors: Array[Color] = []

			for i in range(line_text.length()):
				error_colors.append(COLOR_ERROR)

			return _colors_to_highlighting(
				error_colors,
				_get_default_color()
			)

		for i in range(line_text.length()):
			colors.append(_get_default_color())

		for i in range(_tokens.size()):
			var token := _tokens[i]

			if token.type == LCSSToken.Type.EOF:
				continue

			if token.end_line < line + 1 or token.line > line + 1:
				continue

			var start_column := 0
			var end_column := line_text.length()

			if token.line == line + 1:
				start_column = token.column - 1

			if token.end_line == line + 1:
				end_column = token.end_column - 1

			start_column = clampi(start_column, 0, line_text.length())
			end_column = clampi(end_column, start_column, line_text.length())

			if start_column == end_column:
				continue

			var color := _get_token_color(i)

			for column in range(start_column, end_column):
				colors[column] = color

		return _colors_to_highlighting(colors, _get_default_color())

	func _get_token_color(index: int) -> Color:
		var token := _tokens[index]

		match token.type:
			LCSSToken.Type.COMMENT:
				return COLOR_COMMENT

			LCSSToken.Type.STRING:
				return COLOR_STRING

			LCSSToken.Type.COLOR:
				return COLOR_COLOR

			LCSSToken.Type.NUMBER, \
			LCSSToken.Type.DIMENSION, \
			LCSSToken.Type.PERCENTAGE:
				return COLOR_NUMBER

			LCSSToken.Type.AT_KEYWORD:
				if token.lexeme == LCSS.KEYFRAMES_DIRECTIVE:
					return COLOR_KEYFRAMES
				return COLOR_KEYWORD

			LCSSToken.Type.DOT:
				if _is_selector_dot(index):
					return COLOR_SELECTOR

			LCSSToken.Type.IDENTIFIER:
				return _get_identifier_color(index)

		return _get_default_color()

	func _get_identifier_color(index: int) -> Color:
		var token := _tokens[index]
		var previous := _previous_significant(index)
		var next := _next_significant(index)

		# Nome da animação depois de @keyframes.
		if previous >= 0:
			if _tokens[previous].type == LCSSToken.Type.AT_KEYWORD:
				if _tokens[previous].lexeme == LCSS.KEYFRAMES_DIRECTIVE:
					return COLOR_KEYFRAMES

		# Classes e pseudoestados.
		if previous >= 0:
			var previous_type: int = _tokens[previous].type

			if previous_type == LCSSToken.Type.DOT:
				return COLOR_SELECTOR

			if previous_type == LCSSToken.Type.COLON:
				if LCSS.PSEUDO_STATES.has(token.lexeme):
					return COLOR_STATE

		# Propriedade seguida de dois-pontos.
		if next >= 0 and _tokens[next].type == LCSSToken.Type.COLON:
			if _is_known_property(token.lexeme):
				return COLOR_PROPERTY

		# Seletores de keyframes.
		if token.lexeme in [LCSS.KEYFRAME_FROM, LCSS.KEYFRAME_TO]:
			if next >= 0 and _tokens[next].type == LCSSToken.Type.LBRACE:
				return COLOR_KEYWORD

		# Funções.
		if next >= 0 and _tokens[next].type == LCSSToken.Type.LPAREN:
			return COLOR_FUNCTION

		if LCSS.KEYWORDS.has(token.lexeme):
			return COLOR_KEYWORD

		if _values.has(token.lexeme):
			return COLOR_FUNCTION

		return _get_default_color()

	func _is_selector_dot(index: int) -> bool:
		var next := _next_significant(index)

		if next < 0:
			return false

		return _tokens[next].type == LCSSToken.Type.IDENTIFIER

	func _is_known_property(property_name: String) -> bool:
		if _properties.has(property_name):
			return true

		# Permite prefixos em propriedades compostas.
		# Ex.: header_panel_background_color.
		for key: Variant in _properties:
			if property_name.ends_with("_" + str(key)):
				return true

		return false

	func _previous_significant(index: int) -> int:
		var i := index - 1

		while i >= 0:
			if _tokens[i].type != LCSSToken.Type.COMMENT:
				return i
			i -= 1

		return -1

	func _next_significant(index: int) -> int:
		var i := index + 1

		while i < _tokens.size():
			if _tokens[i].type != LCSSToken.Type.COMMENT:
				return i
			i += 1

		return -1

	func _colors_to_highlighting(
		colors: Array[Color],
		default_color: Color
	) -> Dictionary:
		var result: Dictionary = {}
		var previous_color := default_color

		for i in range(colors.size()):
			var color := colors[i]

			if color != previous_color:
				result[i] = {"color": color}
				previous_color = color

		return result

	func _get_default_color() -> Color:
		var text_edit := get_text_edit()

		if is_instance_valid(text_edit):
			if text_edit.has_theme_color("font_color"):
				return text_edit.get_theme_color("font_color")

		return COLOR_DEFAULT
