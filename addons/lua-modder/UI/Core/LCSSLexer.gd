class_name LCSSLexer extends RefCounted


var _source: String = ""
var _position: int = 0
var _line: int = 1
var _column: int = 1


func tokenize(source: String) -> Array[LCSSToken]:
	_source = source
	_position = 0
	_line = 1
	_column = 1

	var tokens: Array[LCSSToken] = []

	while not _is_at_end():
		var character := _peek()

		if _is_whitespace(character):
			_advance()
			continue

		if _starts_with(LCSS.LINE_COMMENT_START):
			tokens.append(_scan_line_comment())
			continue

		if _starts_with(LCSS.BLOCK_COMMENT_START):
			tokens.append(_scan_block_comment())
			continue

		if _peek() == LCSS.STRING_DOUBLE_QUOTE:
			tokens.append(_scan_string(LCSS.STRING_DOUBLE_QUOTE))
			continue

		if _peek() == LCSS.STRING_SINGLE_QUOTE:
			tokens.append(_scan_string(LCSS.STRING_SINGLE_QUOTE))
			continue

		if _peek() == LCSS.AT_MARKER:
			tokens.append(_scan_at_keyword())
			continue

		if _peek() == LCSS.COLOR_MARKER:
			tokens.append(_scan_hash_or_color())
			continue

		if _is_digit(character):
			tokens.append(_scan_number())
			continue

		if character == "." and _is_digit(_peek(1)):
			tokens.append(_scan_number())
			continue

		if _is_identifier_start(character):
			tokens.append(_scan_identifier())
			continue

		var token := _scan_punctuation()

		if token != null:
			tokens.append(token)
		else:
			tokens.append(_scan_unknown())

	tokens.append(
		LCSSToken.new(
			LCSSToken.Type.EOF,
			"",
			_position,
			_position,
			_line,
			_column,
			_line,
			_column
		)
	)

	return tokens


func _starts_with(value: String) -> bool:
	return _source.substr(_position, value.length()) == value


func _scan_identifier() -> LCSSToken:
	var start_offset := _position
	var start_line := _line
	var start_column := _column

	while _is_identifier_char(_peek()):
		_advance()

	return _make_token(
		LCSSToken.Type.IDENTIFIER,
		start_offset,
		start_line,
		start_column
	)


func _scan_at_keyword() -> LCSSToken:
	var start_offset := _position
	var start_line := _line
	var start_column := _column

	_advance()

	while _is_identifier_char(_peek()):
		_advance()

	return _make_token(
		LCSSToken.Type.AT_KEYWORD,
		start_offset,
		start_line,
		start_column
	)



func _scan_number() -> LCSSToken:
	var start_offset := _position
	var start_line := _line
	var start_column := _column

	if _peek() == LCSS.STYLE_MARKER:
		_advance()
		while _is_digit(_peek()):
			_advance()
	else:
		while _is_digit(_peek()):
			_advance()
		if _peek() == LCSS.STYLE_MARKER and _is_digit(_peek(1)):
			_advance()
			while _is_digit(_peek()):
				_advance()

	var token_type: int = LCSSToken.Type.NUMBER
	if _peek() == "%":
		_advance()
		token_type = LCSSToken.Type.PERCENTAGE
	else:
		for unit in LCSS.DIMENSION_UNITS:
			if _starts_with(unit):
				var next_character := _peek(unit.length())
				if not _is_identifier_char(next_character):
					for i in range(unit.length()):
						_advance()
					token_type = LCSSToken.Type.DIMENSION
					break

	return _make_token(token_type, start_offset, start_line, start_column)



func _scan_hash_or_color() -> LCSSToken:
	var start_offset := _position
	var start_line := _line
	var start_column := _column

	var hex_length := _count_hex_digits(1)

	if hex_length in [3, 4, 6, 8]:
		_advance()

		for i in range(hex_length):
			_advance()

		return _make_token(
			LCSSToken.Type.COLOR,
			start_offset,
			start_line,
			start_column
		)

	_advance()

	return _make_token(
		LCSSToken.Type.HASH,
		start_offset,
		start_line,
		start_column
	)


func _scan_string(quote: String) -> LCSSToken:
	var start_offset := _position
	var start_line := _line
	var start_column := _column

	_advance()

	while not _is_at_end():
		var character := _peek()

		if character == quote:
			_advance()

			return _make_token(
				LCSSToken.Type.STRING,
				start_offset,
				start_line,
				start_column
			)

		if character == "\\":
			_advance()

			if not _is_at_end():
				_advance()

			continue

		_advance()

	return _make_token(
		LCSSToken.Type.STRING,
		start_offset,
		start_line,
		start_column,
		false
	)


func _scan_line_comment() -> LCSSToken:
	var start_offset := _position
	var start_line := _line
	var start_column := _column

	for i in range(LCSS.LINE_COMMENT_START.length()):
		_advance()

	while not _is_at_end() and _peek() != "\n":
		_advance()

	return _make_token(
		LCSSToken.Type.COMMENT,
		start_offset,
		start_line,
		start_column
	)


func _scan_block_comment() -> LCSSToken:
	var start_offset := _position
	var start_line := _line
	var start_column := _column

	for i in range(LCSS.BLOCK_COMMENT_START.length()):
		_advance()

	while not _is_at_end():
		if _starts_with(LCSS.BLOCK_COMMENT_END):
			for i in range(LCSS.BLOCK_COMMENT_END.length()):
				_advance()

			return _make_token(
				LCSSToken.Type.COMMENT,
				start_offset,
				start_line,
				start_column
			)

		_advance()

	return _make_token(
		LCSSToken.Type.COMMENT,
		start_offset,
		start_line,
		start_column,
		false
	)


func _scan_punctuation() -> LCSSToken:
	var character := _peek()
	var token_type: int = LCSSToken.Type.UNKNOWN

	match character:
		"{":
			token_type = LCSSToken.Type.LBRACE
		"}":
			token_type = LCSSToken.Type.RBRACE
		":":
			token_type = LCSSToken.Type.COLON
		";":
			token_type = LCSSToken.Type.SEMICOLON
		",":
			token_type = LCSSToken.Type.COMMA
		".":
			token_type = LCSSToken.Type.DOT
		"(":
			token_type = LCSSToken.Type.LPAREN
		")":
			token_type = LCSSToken.Type.RPAREN
		"[":
			token_type = LCSSToken.Type.LBRACKET
		"]":
			token_type = LCSSToken.Type.RBRACKET
		"+":
			token_type = LCSSToken.Type.PLUS
		"-":
			token_type = LCSSToken.Type.MINUS
		_:
			return null

	var start_offset := _position
	var start_line := _line
	var start_column := _column

	_advance()

	return _make_token(
		token_type,
		start_offset,
		start_line,
		start_column
	)


func _scan_unknown() -> LCSSToken:
	var start_offset := _position
	var start_line := _line
	var start_column := _column

	_advance()

	return _make_token(
		LCSSToken.Type.UNKNOWN,
		start_offset,
		start_line,
		start_column
	)


func _make_token(
	token_type: int,
	start_offset: int,
	start_line: int,
	start_column: int,
	is_terminated: bool = true
) -> LCSSToken:
	return LCSSToken.new(
		token_type,
		_source.substr(start_offset, _position - start_offset),
		start_offset,
		_position,
		start_line,
		start_column,
		_line,
		_column,
		is_terminated
	)


func _count_hex_digits(start_offset: int) -> int:
	var count := 0
	var index := start_offset

	while _is_hex_digit(_peek(index)):
		count += 1
		index += 1

	return count


func _peek(offset: int = 0) -> String:
	var index := _position + offset
	if index < 0 or index >= _source.length():
		return ""
	return _source.substr(index, 1)


func _advance() -> String:
	if _is_at_end():
		return ""

	var character := _source.substr(_position, 1)
	_position += 1

	if character == "\n":
		_line += 1
		_column = 1
	else:
		_column += 1

	return character


func _is_at_end() -> bool:
	return _position >= _source.length()


func _is_whitespace(character: String) -> bool:
	return (
		character == " "
		or character == "\t"
		or character == "\r"
		or character == "\n"
	)


func _is_digit(character: String) -> bool:
	return character >= "0" and character <= "9"


func _is_hex_digit(character: String) -> bool:
	return (
		_is_digit(character)
		or (character >= "a" and character <= "f")
		or (character >= "A" and character <= "F")
	)


func _is_identifier_start(character: String) -> bool:
	return (
		(character >= "a" and character <= "z")
		or (character >= "A" and character <= "Z")
		or character == "_"
	)


func _is_identifier_char(character: String) -> bool:
	return (
		_is_identifier_start(character)
		or _is_digit(character)
		or character == "-"
	)
