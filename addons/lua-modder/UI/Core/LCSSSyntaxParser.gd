@tool
class_name LCSSSyntaxParser extends RefCounted


var errors: Array[Dictionary] = []

var _source: String = ""
var _tokens: Array[LCSSToken] = []
var _position: int = 0

var _selector_validator := LCSSSelectorValidator.new()


func parse(source: String) -> LCSSStyleSheetNode:
	_source = source
	_position = 0
	errors.clear()

	var lexer := LCSSLexer.new()
	_tokens = lexer.tokenize(source)

	var ast := LCSSStyleSheetNode.new()

	if _tokens.is_empty():
		return ast

	ast.set_start(_tokens[0])

	while not _check(LCSSToken.Type.EOF):
		_skip_comments()

		if _check(LCSSToken.Type.EOF):
			break

		if _check(LCSSToken.Type.RBRACE):
			_add_error(
				"Chave de fechamento inesperada.",
				_current()
			)
			_advance()
			continue

		if _check(LCSSToken.Type.AT_KEYWORD):
			if _current().lexeme == LCSS.KEYFRAMES_DIRECTIVE:
				var keyframes := _parse_keyframes()

				if keyframes != null:
					ast.nodes.append(keyframes)
			else:
				_add_error(
					"Diretiva não suportada: %s."
					% _current().lexeme,
					_current()
				)
				_synchronize_top_level()

			continue

		var rule := _parse_rule()

		if rule != null:
			ast.nodes.append(rule)

	var eof := _current()
	ast.set_end(eof)
	ast.errors = errors.duplicate(true)

	var semantic_validator := LCSSSemanticValidator.new()
	errors.append_array(semantic_validator.validate_stylesheet(ast))

	ast.errors = errors
	return ast


func _parse_keyframes() -> LCSSKeyframesNode:
	var directive_token := _current()
	var node := LCSSKeyframesNode.new()
	node.set_start(directive_token)

	_advance()
	_skip_comments()

	if not _check(LCSSToken.Type.IDENTIFIER):
		_add_error(
			"Esperado o nome da animação após @keyframes.",
			_current()
		)
		_synchronize_top_level()
		return null

	node.animation_name = _current().lexeme
	_advance()

	_skip_comments()

	while (
		not _check(LCSSToken.Type.LBRACE)
		and not _check(LCSSToken.Type.EOF)
	):
		_add_error(
			"Token inesperado na declaração de @keyframes.",
			_current()
		)
		_advance()

	if _check(LCSSToken.Type.EOF):
		_add_error(
			"Esperado '{' após o nome da animação.",
			_current()
		)
		node.set_end(_current())
		return node

	_advance()

	while not _check(LCSSToken.Type.RBRACE):
		_skip_comments()

		if _check(LCSSToken.Type.EOF):
			_add_error(
				"Bloco @keyframes não foi fechado com '}'.",
				_current()
			)
			node.set_end(_current())
			return node

		if _check(LCSSToken.Type.AT_KEYWORD):
			_add_error(
				"Diretivas não são permitidas dentro de @keyframes.",
				_current()
			)
			_synchronize_declaration()
			continue

		var frame := _parse_keyframe_frame()

		if frame != null:
			node.frames.append(frame)

	var closing_token := _advance()
	node.set_end(closing_token)

	return node


func _parse_rule() -> LCSSRuleNode:
	_skip_comments()

	if _check(LCSSToken.Type.EOF):
		return null

	var start_index := _position
	var start_token := _current()

	while (
		not _check(LCSSToken.Type.LBRACE)
		and not _check(LCSSToken.Type.RBRACE)
		and not _check(LCSSToken.Type.EOF)
	):
		_advance()

	if not _check(LCSSToken.Type.LBRACE):
		_add_error(
			"Esperado '{' após o seletor.",
			_current()
		)
		_synchronize_top_level()
		return null

	var node := LCSSRuleNode.new()
	node.set_start(start_token)

	node.selectors = _parse_selector_list(
		start_index,
		_position
	)

	_validate_rule_selectors(node, start_token)

	if node.selectors.is_empty():
		_add_error(
			"Uma regra precisa ter pelo menos um seletor.",
			start_token
		)

	_advance()
	_parse_declaration_block(node, "Bloco de regra")

	return node


func _parse_keyframe_frame() -> LCSSRuleNode:
	_skip_comments()

	if (
		_check(LCSSToken.Type.EOF)
		or _check(LCSSToken.Type.RBRACE)
	):
		return null

	var start_index := _position
	var start_token := _current()

	while (
		not _check(LCSSToken.Type.LBRACE)
		and not _check(LCSSToken.Type.RBRACE)
		and not _check(LCSSToken.Type.EOF)
	):
		_advance()

	if not _check(LCSSToken.Type.LBRACE):
		_add_error(
			"Esperado '{' após o seletor do frame.",
			_current()
		)
		return null

	var node := LCSSRuleNode.new()
	node.set_start(start_token)

	node.selectors = _parse_selector_list(
		start_index,
		_position
	)

	if node.selectors.is_empty():
		_add_error(
			"Um frame precisa ter pelo menos um seletor.",
			start_token
		)

	_advance()
	_parse_declaration_block(node, "Bloco de frame")

	return node


func _parse_declaration_block(
	node: LCSSRuleNode,
	block_name: String
) -> void:
	while not _check(LCSSToken.Type.RBRACE):
		_skip_comments()

		if _check(LCSSToken.Type.EOF):
			_add_error(
				"%s não foi fechado com '}'."
				% block_name,
				_current()
			)
			node.set_end(_current())
			return

		if _check(LCSSToken.Type.LBRACE):
			_add_error(
				"Blocos aninhados não são suportados neste contexto.",
				_current()
			)
			_synchronize_declaration()
			continue

		var declaration := _parse_declaration()

		if declaration != null:
			node.declarations.append(declaration)

	var closing_brace := _advance()
	node.set_end(closing_brace)


func _parse_declaration() -> LCSSDeclarationNode:
	_skip_comments()

	if (
		_check(LCSSToken.Type.RBRACE)
		or _check(LCSSToken.Type.EOF)
	):
		return null

	var start_index := _position
	var start_token := _current()

	while (
		not _check(LCSSToken.Type.COLON)
		and not _check(LCSSToken.Type.SEMICOLON)
		and not _check(LCSSToken.Type.RBRACE)
		and not _check(LCSSToken.Type.EOF)
	):
		_advance()

	if not _check(LCSSToken.Type.COLON):
		_add_error(
			"Esperado ':' após o nome da propriedade.",
			start_token
		)
		_synchronize_declaration()
		return null

	var property_tokens: Array[LCSSToken] = []

	for i in range(start_index, _position):
		if _tokens[i].type != LCSSToken.Type.COMMENT:
			property_tokens.append(_tokens[i])

	if (
		property_tokens.size() != 1
		or property_tokens[0].type != LCSSToken.Type.IDENTIFIER
	):
		_add_error(
			"O nome da propriedade deve ser um identificador.",
			start_token
		)
		_synchronize_declaration()
		return null

	var node := LCSSDeclarationNode.new()
	node.set_start(start_token)
	node.property_name = property_tokens[0].lexeme

	_advance()

	var value_start_index := _position
	var paren_depth := 0
	var bracket_depth := 0

	while not _check(LCSSToken.Type.EOF):
		var token := _current()

		if (
			token.type == LCSSToken.Type.SEMICOLON
			and paren_depth == 0
			and bracket_depth == 0
		):
			break

		if (
			token.type == LCSSToken.Type.RBRACE
			and paren_depth == 0
			and bracket_depth == 0
		):
			break

		match token.type:
			LCSSToken.Type.LPAREN:
				paren_depth += 1

			LCSSToken.Type.RPAREN:
				if paren_depth == 0:
					_add_error(
						"Parêntese de fechamento inesperado no valor.",
						token
					)
				else:
					paren_depth -= 1

			LCSSToken.Type.LBRACKET:
				bracket_depth += 1

			LCSSToken.Type.RBRACKET:
				if bracket_depth == 0:
					_add_error(
						"Colchete de fechamento inesperado no valor.",
						token
					)
				else:
					bracket_depth -= 1

		_advance()

	if paren_depth > 0:
		_add_error(
			"Parêntese não foi fechado no valor da propriedade.",
			start_token
		)

	if bracket_depth > 0:
		_add_error(
			"Colchete não foi fechado no valor da propriedade.",
			start_token
		)

	for i in range(value_start_index, _position):
		node.value_tokens.append(_tokens[i])

	if not node.value_tokens.is_empty():
		var first_value_token := node.value_tokens[0]
		var last_value_token := node.value_tokens[-1]

		node.value_text = _source.substr(
			first_value_token.start_offset,
			last_value_token.end_offset - first_value_token.start_offset
		).strip_edges()

	if node.value_tokens.is_empty() or node.value_text.is_empty():
		_add_error(
			"A propriedade '%s' precisa ter um valor."
			% node.property_name,
			start_token
		)

	if _check(LCSSToken.Type.SEMICOLON):
		node.set_end(_advance())
	elif not node.value_tokens.is_empty():
		node.set_end(node.value_tokens[-1])
	else:
		node.set_end(_current())

	return node


func _parse_selector_list(
	start_index: int,
	end_index: int
) -> PackedStringArray:
	var selectors := PackedStringArray()
	var segment_start := start_index

	for i in range(start_index, end_index + 1):
		var at_end := i == end_index
		var is_separator := (
			not at_end
			and _tokens[i].type == LCSSToken.Type.COMMA
		)

		if not at_end and not is_separator:
			continue

		var first_token: LCSSToken = null
		var last_token: LCSSToken = null

		for j in range(segment_start, i):
			if _tokens[j].type == LCSSToken.Type.COMMENT:
				continue

			if first_token == null:
				first_token = _tokens[j]

			last_token = _tokens[j]

		if first_token != null and last_token != null:
			var selector := _source.substr(
				first_token.start_offset,
				last_token.end_offset - first_token.start_offset
			).strip_edges()

			if not selector.is_empty():
				selectors.append(selector)

		segment_start = i + 1

	return selectors


func _synchronize_declaration() -> void:
	var paren_depth := 0
	var bracket_depth := 0

	while not _check(LCSSToken.Type.EOF):
		var token := _current()

		if (
			token.type == LCSSToken.Type.RBRACE
			and paren_depth == 0
			and bracket_depth == 0
		):
			return

		if (
			token.type == LCSSToken.Type.SEMICOLON
			and paren_depth == 0
			and bracket_depth == 0
		):
			_advance()
			return

		match token.type:
			LCSSToken.Type.LPAREN:
				paren_depth += 1
			LCSSToken.Type.RPAREN:
				paren_depth = maxi(0, paren_depth - 1)
			LCSSToken.Type.LBRACKET:
				bracket_depth += 1
			LCSSToken.Type.RBRACKET:
				bracket_depth = maxi(0, bracket_depth - 1)

		_advance()


func _synchronize_top_level() -> void:
	while not _check(LCSSToken.Type.EOF):
		if _check(LCSSToken.Type.RBRACE):
			_advance()
			return

		if _check(LCSSToken.Type.LBRACE):
			_advance()
			var depth := 1

			while depth > 0 and not _check(LCSSToken.Type.EOF):
				if _check(LCSSToken.Type.LBRACE):
					depth += 1
				elif _check(LCSSToken.Type.RBRACE):
					depth -= 1

				_advance()

			return

		_advance()


func _validate_rule_selectors(
	node: LCSSRuleNode,
	start_token: LCSSToken
) -> void:
	var search_offset := start_token.start_offset

	for selector in node.selectors:
		var validation_error := _selector_validator.validate_selector(
			selector
		)

		if validation_error.is_empty():
			var selector_offset := _source.find(
				selector,
				search_offset
			)

			if selector_offset >= 0:
				search_offset = selector_offset + selector.length()

			continue

		var selector_offset := _source.find(
			selector,
			search_offset
		)

		if selector_offset < 0:
			selector_offset = start_token.start_offset
		else:
			search_offset = selector_offset + selector.length()

		var error_offset: int = (
			selector_offset
			+ int(validation_error.get("offset", 0))
		)

		_add_error_at_offset(
			"Seletor inválido: %s"
			% validation_error["message"],
			error_offset
		)


func _add_error_at_offset(
	message: String,
	offset: int
) -> void:
	var safe_offset := clampi(offset, 0, _source.length())
	var line := 1
	var column := 1

	for i in range(safe_offset):
		if _source[i] == "\n":
			line += 1
			column = 1
		else:
			column += 1

	errors.append({
		"message": message,
		"offset": safe_offset,
		"line": line,
		"column": column,
	})


func _skip_comments() -> void:
	while _check(LCSSToken.Type.COMMENT):
		_advance()


func _current() -> LCSSToken:
	return _tokens[mini(_position, _tokens.size() - 1)]


func _check(type: int) -> bool:
	return _current().type == type


func _advance() -> LCSSToken:
	var token := _current()

	if not _check(LCSSToken.Type.EOF):
		_position += 1

	return token


func _add_error(message: String, token: LCSSToken) -> void:
	errors.append({
		"message": message,
		"offset": token.start_offset,
		"line": token.line,
		"column": token.column,
	})
