@tool
class_name LCSSSyntaxHighlighter extends EditorSyntaxHighlighter


const COLOR_DEFAULT := Color.WHITE
const COLOR_SELECTOR := Color("#80CBC4")
const COLOR_STATE := Color("ff731eff")
const COLOR_KEYFRAMES := Color("#CE93D8")
const COLOR_PROPERTY := Color("#90CAF9")
const COLOR_FUNCTION := Color("#FFCC80")
const COLOR_NUMBER := Color("#F48FB1")
const COLOR_STRING := Color("#A5D6A7")
const COLOR_COMMENT := Color("#78909C")
const COLOR_COLOR := Color("#EF9A9A")
const COLOR_KEYWORD := Color("#CE93D8")

const KEYFRAMES := "@keyframes"


func _get_name() -> String:
	return "LCSS"


func _get_supported_languages() -> PackedStringArray:
	return ["TextFile"]


func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var text_edit := get_text_edit()
	if not is_instance_valid(text_edit):
		return {}

	var in_block_comment := false

	for previous_line in range(line):
		var previous_text := text_edit.get_line(previous_line)
		var scan := _scan_line(previous_text, in_block_comment, false)
		in_block_comment = scan["in_block_comment"]

	var scan := _scan_line(
		text_edit.get_line(line),
		in_block_comment,
		true
	)

	return _colors_to_highlighting(
		scan["colors"],
		_get_default_color()
	)


func _scan_line(
	line_text: String,
	starts_in_block_comment: bool,
	paint: bool
) -> Dictionary:
	var default_color := _get_default_color()
	var colors: Array[Color] = []

	for i in range(line_text.length()):
		colors.append(default_color)

	var i := 0
	var in_block_comment := starts_in_block_comment

	while i < line_text.length():
		var current := line_text.substr(i, 1)

		if in_block_comment:
			var comment_end := line_text.find("*/", i)

			if comment_end == -1:
				_paint(colors, i, line_text.length(), COLOR_COMMENT, paint)
				i = line_text.length()
				break

			_paint(colors, i, comment_end + 2, COLOR_COMMENT, paint)
			i = comment_end + 2
			in_block_comment = false
			continue

		# Strings
		if current == "\"" or current == "'":
			var string_end := _find_string_end(line_text, i, current)
			_paint(colors, i, string_end, COLOR_STRING, paint)
			i = string_end
			continue

		# Single-line comments
		if line_text.substr(i, 2) == "//":
			_paint(colors, i, line_text.length(), COLOR_COMMENT, paint)
			break

		# Multi-line comments
		if line_text.substr(i, 2) == "/*":
			var comment_end := line_text.find("*/", i + 2)

			if comment_end == -1:
				_paint(colors, i, line_text.length(), COLOR_COMMENT, paint)
				in_block_comment = true
				break

			_paint(colors, i, comment_end + 2, COLOR_COMMENT, paint)
			i = comment_end + 2
			continue

		# @keyframes and animation name
		if line_text.substr(i, KEYFRAMES.length()) == KEYFRAMES:
			var after_directive := i + KEYFRAMES.length()

			if (
				after_directive == line_text.length()
				or _is_whitespace(line_text.substr(after_directive, 1))
				or line_text.substr(after_directive, 1) == "{"
			):
				_paint(
					colors,
					i,
					after_directive,
					COLOR_KEYFRAMES,
					paint
				)

				i = after_directive

				while (
					i < line_text.length()
					and _is_whitespace(line_text.substr(i, 1))
				):
					i += 1

				var name_end := i

				while name_end < line_text.length():
					var c := line_text.substr(name_end, 1)

					if (
						_is_whitespace(c)
						or c == "{"
						or c == ","
					):
						break

					name_end += 1

				if name_end > i:
					_paint(colors, i, name_end, COLOR_KEYFRAMES, paint)
					i = name_end

				continue

		# Hexadecimal colors
		if current == "#":
			var hex_end := i + 1

			while (
				hex_end < line_text.length()
				and _is_hex_digit(line_text.substr(hex_end, 1))
			):
				hex_end += 1

			var hex_length := hex_end - i - 1

			if hex_length in [3, 4, 6, 8]:
				_paint(colors, i, hex_end, COLOR_COLOR, paint)
				i = hex_end
				continue

		# Class selectors and their states:
		# .button:hover, .button:pressed, .button:focus
		if current == "." and i + 1 < line_text.length():
			var next_char := line_text.substr(i + 1, 1)

			if _is_identifier_start(next_char):
				var class_end := i + 2

				while (
					class_end < line_text.length()
					and _is_identifier_char(line_text.substr(class_end, 1))
				):
					class_end += 1

				_paint(colors, i, class_end, COLOR_SELECTOR, paint)
				i = class_end

				while i < line_text.length():
					if line_text.substr(i, 1) != ":":
						break

					var state_start := i
					var state_name_start := i + 1

					if (
						state_name_start >= line_text.length()
						or not _is_identifier_start(
							line_text.substr(state_name_start, 1)
						)
					):
						break

					var state_end := state_name_start + 1

					while (
						state_end < line_text.length()
						and _is_identifier_char(line_text.substr(state_end, 1))
					):
						state_end += 1

					_paint(
						colors,
						state_start,
						state_end,
						COLOR_STATE,
						paint
					)

					i = state_end

				continue

		# Numbers, decimals, percentages and durations
		if _is_digit(current) or (
			current == "."
			and i + 1 < line_text.length()
			and _is_digit(line_text.substr(i + 1, 1))
		):
			var end := _scan_number(line_text, i)
			_paint(colors, i, end, COLOR_NUMBER, paint)
			i = end
			continue

		# Identifiers: properties, functions and keyframe selectors
		if _is_identifier_start(current):
			var end := i + 1

			while (
				end < line_text.length()
				and _is_identifier_char(line_text.substr(end, 1))
			):
				end += 1

			var identifier := line_text.substr(i, end - i)
			var next_non_whitespace := _skip_whitespace(line_text, end)

			if (
				identifier in ["from", "to"]
				and next_non_whitespace < line_text.length()
				and line_text.substr(next_non_whitespace, 1) == "{"
			):
				_paint(colors, i, end, COLOR_KEYWORD, paint)

			elif (
				next_non_whitespace < line_text.length()
				and line_text.substr(next_non_whitespace, 1) == ":"
			):
				_paint(colors, i, end, COLOR_PROPERTY, paint)

			elif (
				end < line_text.length()
				and line_text.substr(end, 1) == "("
			):
				_paint(colors, i, end, COLOR_FUNCTION, paint)

			i = end
			continue

		i += 1

	return {
		"colors": colors,
		"in_block_comment": in_block_comment
	}


func _find_string_end(text: String, start: int, quote: String) -> int:
	var i := start + 1

	while i < text.length():
		var c := text.substr(i, 1)

		if c == "\\":
			i += 2
			continue

		if c == quote:
			return i + 1

		i += 1

	return text.length()


func _scan_number(text: String, start: int) -> int:
	var i := start
	var has_decimal := false

	if text.substr(i, 1) == ".":
		has_decimal = true
		i += 1

	while i < text.length():
		var c := text.substr(i, 1)

		if _is_digit(c):
			i += 1
		elif c == "." and not has_decimal:
			has_decimal = true
			i += 1
		else:
			break

	if i < text.length() and text.substr(i, 1) == "%":
		return i + 1

	if text.substr(i, 2) == "ms":
		return i + 2

	if i < text.length() and text.substr(i, 1) == "s":
		return i + 1

	return i


func _skip_whitespace(text: String, start: int) -> int:
	var i := start

	while i < text.length() and _is_whitespace(text.substr(i, 1)):
		i += 1

	return i


func _is_whitespace(c: String) -> bool:
	return c == " " or c == "\t" or c == "\r"


func _is_identifier_start(c: String) -> bool:
	if c.is_empty():
		return false

	return c == "_" or c.to_lower() != c.to_upper()


func _is_identifier_char(c: String) -> bool:
	return _is_identifier_start(c) or _is_digit(c) or c == "-"


func _is_digit(c: String) -> bool:
	return c >= "0" and c <= "9"


func _is_hex_digit(c: String) -> bool:
	return _is_digit(c) or c.to_lower() in [
		"a", "b", "c", "d", "e", "f"
	]


func _paint(
	colors: Array[Color],
	start: int,
	end: int,
	color: Color,
	enabled: bool
) -> void:
	if not enabled:
		return

	for i in range(start, mini(end, colors.size())):
		colors[i] = color


func _colors_to_highlighting(
	colors: Array[Color],
	default_color: Color
) -> Dictionary:
	var result := {}
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
		return text_edit.get_theme_color("font_color")

	return COLOR_DEFAULT
