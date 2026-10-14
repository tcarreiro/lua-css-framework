class_name LCSSUnitTestSuite
extends RefCounted


signal test_reported(passed: bool, test_name: String, message: String)


var passed_count: int = 0
var failed_count: int = 0


func run_tests() -> void:
	push_error("LCSSUnitTestSuite.run_tests() precisa ser implementado pela suíte de testes.")


func assert_true(test_name: String, condition: bool, message: String = "") -> bool:
	if condition:
		_pass(test_name)
		return true

	_fail(
		test_name,
		message if not message.is_empty() else "A condição esperada era verdadeira."
	)
	return false


func assert_false(test_name: String, condition: bool, message: String = "") -> bool:
	return assert_true(test_name, not condition, message if not message.is_empty() else "A condição esperada era falsa.")


func assert_equal(test_name: String, expected: Variant, actual: Variant, message: String = "") -> bool:
	if expected == actual:
		_pass(test_name)
		return true

	var failure_message := message
	if failure_message.is_empty():
		failure_message = "Esperado: %s; recebido: %s." % [
			var_to_str(expected),
			var_to_str(actual),
		]

	_fail(test_name, failure_message)
	return false


func assert_sequence(test_name: String, source: String, expected: Array) -> bool:
	var lexer := LCSSLexer.new()
	var tokens: Array[LCSSToken] = lexer.tokenize(source)

	if tokens.size() != expected.size():
		_fail(
			test_name,
			"Quantidade de tokens incorreta. Esperados: %d; recebidos: %d.\n"
			% [expected.size(), tokens.size()]
			+ "Tokens recebidos: %s" % _format_tokens(tokens)
		)
		return false

	for i in range(expected.size()):
		var expected_token: Array = expected[i]
		var actual_token: LCSSToken = tokens[i]

		if expected_token.size() != 2:
			_fail(
				test_name,
				"Definição inválida do token esperado no índice %d." % i
			)
			return false

		var expected_type: int = expected_token[0]
		var expected_lexeme: String = expected_token[1]

		if actual_token.type != expected_type:
			_fail(
				test_name,
				"Token %d: tipo esperado %s, recebido %s. Lexema recebido: '%s'."
				% [
					i,
					_type_name(expected_type),
					_type_name(actual_token.type),
					actual_token.lexeme,
				]
			)
			return false

		if actual_token.lexeme != expected_lexeme:
			_fail(
				test_name,
				"Token %d: lexema esperado '%s', recebido '%s'."
				% [i, expected_lexeme, actual_token.lexeme]
			)
			return false

	_pass(test_name)
	return true


func reset_results() -> void:
	passed_count = 0
	failed_count = 0


func _pass(test_name: String) -> void:
	passed_count += 1
	test_reported.emit(true, test_name, "")


func _fail(test_name: String, message: String) -> void:
	failed_count += 1
	test_reported.emit(false, test_name, message)


func _type_name(type: int) -> String:
	match type:
		LCSSToken.Type.IDENTIFIER:
			return "IDENTIFIER"
		LCSSToken.Type.AT_KEYWORD:
			return "AT_KEYWORD"
		LCSSToken.Type.NUMBER:
			return "NUMBER"
		LCSSToken.Type.DIMENSION:
			return "DIMENSION"
		LCSSToken.Type.PERCENTAGE:
			return "PERCENTAGE"
		LCSSToken.Type.COLOR:
			return "COLOR"
		LCSSToken.Type.HASH:
			return "HASH"
		LCSSToken.Type.STRING:
			return "STRING"
		LCSSToken.Type.COMMENT:
			return "COMMENT"
		LCSSToken.Type.LBRACE:
			return "LBRACE"
		LCSSToken.Type.RBRACE:
			return "RBRACE"
		LCSSToken.Type.COLON:
			return "COLON"
		LCSSToken.Type.SEMICOLON:
			return "SEMICOLON"
		LCSSToken.Type.COMMA:
			return "COMMA"
		LCSSToken.Type.DOT:
			return "DOT"
		LCSSToken.Type.LPAREN:
			return "LPAREN"
		LCSSToken.Type.RPAREN:
			return "RPAREN"
		LCSSToken.Type.LBRACKET:
			return "LBRACKET"
		LCSSToken.Type.RBRACKET:
			return "RBRACKET"
		LCSSToken.Type.PLUS:
			return "PLUS"
		LCSSToken.Type.MINUS:
			return "MINUS"
		LCSSToken.Type.UNKNOWN:
			return "UNKNOWN"
		LCSSToken.Type.EOF:
			return "EOF"
		_:
			return "UNKNOWN_TYPE(%d)" % type


func _format_tokens(tokens: Array[LCSSToken]) -> String:
	var descriptions: PackedStringArray = []

	for token in tokens:
		descriptions.append(
			"[%s, '%s']" % [
				_type_name(token.type),
				token.lexeme.c_escape(),
			]
		)

	return ", ".join(descriptions)
