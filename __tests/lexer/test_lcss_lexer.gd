extends LCSSUnitTestSuite


func run_tests() -> void:
	_test_basic_syntax()
	_test_dimensions()
	_test_colors()
	_test_strings()
	_test_comments()
	_test_custom_states()
	_test_token_positions()


func _test_basic_syntax() -> void:
	assert_sequence(
		"Basic syntax",
		".menu-button { background_color: #ffffff; }",
		[
			[LCSSToken.Type.DOT, "."],
			[LCSSToken.Type.IDENTIFIER, "menu-button"],
			[LCSSToken.Type.LBRACE, "{"],
			[LCSSToken.Type.IDENTIFIER, "background_color"],
			[LCSSToken.Type.COLON, ":"],
			[LCSSToken.Type.COLOR, "#ffffff"],
			[LCSSToken.Type.SEMICOLON, ";"],
			[LCSSToken.Type.RBRACE, "}"],
			[LCSSToken.Type.EOF, ""],
		]
	)


func _test_dimensions() -> void:
	assert_sequence(
		"Known dimensions and unknown suffixes",
		"0ms 1s 1.5s 150ms 2000ms 12abc 150msExtra",
		[
			[LCSSToken.Type.DIMENSION, "0ms"],
			[LCSSToken.Type.DIMENSION, "1s"],
			[LCSSToken.Type.DIMENSION, "1.5s"],
			[LCSSToken.Type.DIMENSION, "150ms"],
			[LCSSToken.Type.DIMENSION, "2000ms"],
			[LCSSToken.Type.NUMBER, "12"],
			[LCSSToken.Type.IDENTIFIER, "abc"],
			[LCSSToken.Type.NUMBER, "150"],
			[LCSSToken.Type.IDENTIFIER, "msExtra"],
			[LCSSToken.Type.EOF, ""],
		]
	)

	assert_sequence(
		"Decimal numbers and signs",
		".5 0.25 -3 +4",
		[
			[LCSSToken.Type.NUMBER, ".5"],
			[LCSSToken.Type.NUMBER, "0.25"],
			[LCSSToken.Type.MINUS, "-"],
			[LCSSToken.Type.NUMBER, "3"],
			[LCSSToken.Type.PLUS, "+"],
			[LCSSToken.Type.NUMBER, "4"],
			[LCSSToken.Type.EOF, ""],
		]
	)

	assert_sequence(
		"Percentage",
		"0% 50% 100%",
		[
			[LCSSToken.Type.PERCENTAGE, "0%"],
			[LCSSToken.Type.PERCENTAGE, "50%"],
			[LCSSToken.Type.PERCENTAGE, "100%"],
			[LCSSToken.Type.EOF, ""],
		]
	)


func _test_colors() -> void:
	assert_sequence(
		"Valid hexadecimal colors",
		"#fff #ffff #ffffff #ffffffff",
		[
			[LCSSToken.Type.COLOR, "#fff"],
			[LCSSToken.Type.COLOR, "#ffff"],
			[LCSSToken.Type.COLOR, "#ffffff"],
			[LCSSToken.Type.COLOR, "#ffffffff"],
			[LCSSToken.Type.EOF, ""],
		]
	)

	var lexer := LCSSLexer.new()
	var tokens: Array[LCSSToken] = lexer.tokenize("#12 #ggg")
	var invalid_color_found := false

	for token in tokens:
		if token.type == LCSSToken.Type.COLOR:
			invalid_color_found = true
			break

	assert_true(
		"Invalid colors are not recognized as COLOR",
		not invalid_color_found,
		"Uma cor inválida foi reconhecida como COLOR."
	)


func _test_strings() -> void:
	assert_sequence(
		"Quoted strings",
		"\"hello world\" 'another string'",
		[
			[LCSSToken.Type.STRING, "\"hello world\""],
			[LCSSToken.Type.STRING, "'another string'"],
			[LCSSToken.Type.EOF, ""],
		]
	)

	assert_sequence(
		"Comment markers inside strings",
		"\"// not a comment\" '/* not a comment */'",
		[
			[LCSSToken.Type.STRING, "\"// not a comment\""],
			[LCSSToken.Type.STRING, "'/* not a comment */'"],
			[LCSSToken.Type.EOF, ""],
		]
	)

	_test_unterminated_string("\"unfinished", "\"unfinished")
	_test_unterminated_string("'unfinished", "'unfinished")


func _test_unterminated_string(
	source: String,
	expected_lexeme: String
) -> void:
	var lexer := LCSSLexer.new()
	var tokens: Array[LCSSToken] = lexer.tokenize(source)

	if not assert_true(
		"Unterminated string tokens: %s" % source,
		tokens.size() >= 2,
		"Tokens insuficientes."
	):
		return

	var token: LCSSToken = tokens[0]

	if not assert_true(
		"Unterminated string type: %s" % source,
		token.type == LCSSToken.Type.STRING,
		"Esperado STRING, recebido %s." % _type_name(token.type)
	):
		return

	if not assert_true(
		"Unterminated string lexeme: %s" % source,
		token.lexeme == expected_lexeme,
		"Lexema inesperado: '%s'." % token.lexeme
	):
		return

	if not assert_true(
		"Unterminated string termination flag: %s" % source,
		not token.is_terminated,
		"String não terminada marcada como terminada."
	):
		return

	assert_true(
		"Unterminated string EOF: %s" % source,
		tokens[-1].type == LCSSToken.Type.EOF,
		"Token EOF ausente."
	)


func _test_comments() -> void:
	assert_sequence(
		"Line and block comments",
		"// line comment\n/* block comment */",
		[
			[LCSSToken.Type.COMMENT, "// line comment"],
			[LCSSToken.Type.COMMENT, "/* block comment */"],
			[LCSSToken.Type.EOF, ""],
		]
	)

	_test_unterminated_comment("/* unfinished comment")


func _test_unterminated_comment(source: String) -> void:
	var lexer := LCSSLexer.new()
	var tokens: Array[LCSSToken] = lexer.tokenize(source)

	if not assert_true(
		"Unterminated block comment tokens",
		tokens.size() >= 2,
		"Tokens insuficientes."
	):
		return

	var token: LCSSToken = tokens[0]

	if not assert_true(
		"Unterminated block comment type",
		token.type == LCSSToken.Type.COMMENT,
		"Esperado COMMENT, recebido %s." % _type_name(token.type)
	):
		return

	if not assert_true(
		"Unterminated block comment termination flag",
		not token.is_terminated,
		"Comentário não terminado marcado como terminado."
	):
		return

	assert_true(
		"Unterminated block comment EOF",
		tokens[-1].type == LCSSToken.Type.EOF,
		"Token EOF ausente."
	)


func _test_custom_states() -> void:
	assert_sequence(
		"Custom states",
		".button:hover .button:my_custom_state .button:state_123",
		[
			[LCSSToken.Type.DOT, "."],
			[LCSSToken.Type.IDENTIFIER, "button"],
			[LCSSToken.Type.COLON, ":"],
			[LCSSToken.Type.IDENTIFIER, "hover"],

			[LCSSToken.Type.DOT, "."],
			[LCSSToken.Type.IDENTIFIER, "button"],
			[LCSSToken.Type.COLON, ":"],
			[LCSSToken.Type.IDENTIFIER, "my_custom_state"],

			[LCSSToken.Type.DOT, "."],
			[LCSSToken.Type.IDENTIFIER, "button"],
			[LCSSToken.Type.COLON, ":"],
			[LCSSToken.Type.IDENTIFIER, "state_123"],

			[LCSSToken.Type.EOF, ""],
		]
	)


func _test_token_positions() -> void:
	var source := "a\n  b"
	var lexer := LCSSLexer.new()
	var tokens: Array[LCSSToken] = lexer.tokenize(source)

	if not assert_true(
		"Token positions: token count",
		tokens.size() == 3,
		"Esperados 3 tokens, recebidos %d." % tokens.size()
	):
		return

	var first: LCSSToken = tokens[0]
	var second: LCSSToken = tokens[1]
	var eof: LCSSToken = tokens[2]

	if not assert_true(
		"Token positions: first token",
		first.lexeme == "a" and first.start_offset == 0,
		"Posição inicial incorreta para 'a'."
	):
		return

	if not assert_true(
		"Token positions: second token offset",
		second.lexeme == "b" and second.start_offset == 4,
		"Offset incorreto para 'b'."
	):
		return

	if not assert_true(
		"Token positions: line and column",
		second.line == 2 and second.column == 3,
		"Esperado linha 2, coluna 3; recebido linha %d, coluna %d."
		% [second.line, second.column]
	):
		return

	assert_true(
		"Token positions: EOF offset",
		eof.start_offset == source.length(),
		"Offset incorreto para EOF."
	)
