
extends LCSSUnitTestSuite


func run_tests() -> void:
	reset_results()

	_test_empty_source()
	_test_single_rule()
	_test_multiple_selectors()
	_test_multiple_declarations()
	_test_declaration_without_trailing_semicolon()
	_test_complex_values()
	_test_comments()
	_test_keyframes()
	_test_source_positions()
	_test_missing_colon()
	_test_error_recovery()
	_test_missing_closing_brace()
	_test_unexpected_closing_brace()
	_test_unsupported_directive()
	_test_keyframes_with_multiple_frames()
	_test_keyframes_missing_frame_brace()
	_test_invalid_selector_generates_error()
	_test_keyframes_are_not_validated_as_class_selectors()
	_test_unknown_property_generates_semantic_error()
	_test_invalid_option_generates_semantic_error()
	_test_semantic_error_has_source_position()


func _test_empty_source() -> void:
	var ast := _parse("")

	assert_equal(
		"Parser: fonte vazia não gera regras",
		0,
		ast.nodes.size()
	)
	assert_equal(
		"Parser: fonte vazia não gera erros",
		0,
		ast.errors.size()
	)


func _test_single_rule() -> void:
	var ast := _parse("""
.button {
	background_color: #ff0000;
}
""")

	assert_equal(
		"Regra simples: quantidade de regras",
		1,
		ast.get_rules().size()
	)
	assert_equal(
		"Regra simples: quantidade de erros",
		0,
		ast.errors.size()
	)

	if ast.get_rules().is_empty():
		return

	var rule := ast.get_rules()[0]

	assert_equal(
		"Regra simples: seletor",
		".button",
		rule.selectors[0]
	)
	assert_equal(
		"Regra simples: quantidade de declarações",
		1,
		rule.declarations.size()
	)

	if rule.declarations.is_empty():
		return

	assert_equal(
		"Regra simples: nome da propriedade",
		"background_color",
		rule.declarations[0].property_name
	)
	assert_equal(
		"Regra simples: valor da propriedade",
		"#ff0000",
		rule.declarations[0].value_text
	)


func _test_multiple_selectors() -> void:
	var ast := _parse("""
.button, .button:hover, .button:focus {
	background_color: #00ff00;
}
""")

	assert_equal(
		"Seletores múltiplos: quantidade",
		3,
		ast.get_rules()[0].selectors.size()
	)

	if ast.get_rules().is_empty():
		return

	var selectors := ast.get_rules()[0].selectors

	assert_equal(
		"Seletores múltiplos: primeiro seletor",
		".button",
		selectors[0]
	)
	assert_equal(
		"Seletores múltiplos: segundo seletor",
		".button:hover",
		selectors[1]
	)
	assert_equal(
		"Seletores múltiplos: terceiro seletor",
		".button:focus",
		selectors[2]
	)
	assert_equal(
		"Seletores múltiplos: sem erros",
		0,
		ast.errors.size()
	)


func _test_multiple_declarations() -> void:
	var ast := _parse("""
.card {
	background_color: #202020;
	border_width: 2;
	border_radius: 12;
	padding: [8, 16];
}
""")

	assert_equal(
		"Declarações múltiplas: quantidade de regras",
		1,
		ast.get_rules().size()
	)

	if ast.get_rules().is_empty():
		return

	var rule := ast.get_rules()[0]

	assert_equal(
		"Declarações múltiplas: quantidade de declarações",
		4,
		rule.declarations.size()
	)

	if rule.declarations.size() != 4:
		return

	assert_equal(
		"Declarações múltiplas: primeira propriedade",
		"background_color",
		rule.declarations[0].property_name
	)
	assert_equal(
		"Declarações múltiplas: segunda propriedade",
		"border_width",
		rule.declarations[1].property_name
	)
	assert_equal(
		"Declarações múltiplas: terceira propriedade",
		"border_radius",
		rule.declarations[2].property_name
	)
	assert_equal(
		"Declarações múltiplas: quarta propriedade",
		"padding",
		rule.declarations[3].property_name
	)
	assert_equal(
		"Declarações múltiplas: sem erros",
		0,
		ast.errors.size()
	)


func _test_declaration_without_trailing_semicolon() -> void:
	var ast := _parse("""
.button {
	background_color: #ff0000;
	padding: 8
}
""")

	assert_equal(
		"Sem ponto e vírgula final: quantidade de erros",
		0,
		ast.errors.size()
	)

	if ast.get_rules().is_empty():
		return

	var declarations := ast.get_rules()[0].declarations

	assert_equal(
		"Sem ponto e vírgula final: declarações preservadas",
		2,
		declarations.size()
	)

	if declarations.size() != 2:
		return

	assert_equal(
		"Sem ponto e vírgula final: valor da última declaração",
		"8",
		declarations[1].value_text
	)


func _test_complex_values() -> void:
	var ast := _parse("""
		.panel {
			padding: [8, 16];
			background_color: Vector2(10, -20);
			border_width: ease_in_out 200ms;
			border_radius: "Open Sans";
			drop_shadow_offset: 0.5;
			border_color: true;
		}
		""")

	assert_equal(
		"Valores complexos: quantidade de erros",
		0,
		ast.errors.size()
	)

	if ast.get_rules().is_empty():
		return

	var rule := ast.get_rules()[0]

	assert_equal(
		"Valores complexos: quantidade de declarações",
		6,
		rule.declarations.size()
	)

	assert_equal(
		"Valores complexos: array",
		"[8, 16]",
		_get_value(rule, "padding")
	)
	assert_equal(
		"Valores complexos: função e números negativos",
		"Vector2(10, -20)",
		_get_value(rule, "background_color")
	)
	assert_equal(
		"Valores complexos: unidade de tempo",
		"ease_in_out 200ms",
		_get_value(rule, "border_width")
	)
	assert_equal(
		"Valores complexos: string",
		'"Open Sans"',
		_get_value(rule, "border_radius")
	)
	assert_equal(
		"Valores complexos: decimal",
		"0.5",
		_get_value(rule, "drop_shadow_offset")
	)
	assert_equal(
		"Valores complexos: booleano",
		"true",
		_get_value(rule, "border_color")
	)


func _test_comments() -> void:
	var ast := _parse("""
/* Comentário antes da regra */
.button {
	// Comentário dentro da regra
	background_color: #ff0000;
}

/* Comentário entre regras */
.label {
	color: #ffffff;
}
""")

	assert_equal(
		"Comentários: quantidade de regras",
		2,
		ast.get_rules().size()
	)
	assert_equal(
		"Comentários: quantidade de erros",
		0,
		ast.errors.size()
	)

	if ast.get_rules().size() != 2:
		return

	assert_equal(
		"Comentários: primeira regra preservada",
		".button",
		ast.get_rules()[0].selectors[0]
	)
	assert_equal(
		"Comentários: segunda regra preservada",
		".label",
		ast.get_rules()[1].selectors[0]
	)


func _test_keyframes() -> void:
	var ast := _parse("""
		@keyframes fade_in {
			from {
				padding: 0;
			}
			50% {
				padding: 8;
			}
			to {
				padding: 16;
			}
	}
	""")

	assert_equal(
		"Keyframes: quantidade de animações",
		1,
		ast.get_keyframes().size()
	)
	assert_equal(
		"Keyframes: quantidade de erros",
		0,
		ast.errors.size()
	)

	if ast.get_keyframes().is_empty():
		return

	var animation := ast.get_keyframes()[0]

	assert_equal(
		"Keyframes: nome da animação",
		"fade_in",
		animation.animation_name
	)
	assert_equal(
		"Keyframes: quantidade de quadros",
		3,
		animation.frames.size()
	)

	if animation.frames.size() != 3:
		return

	assert_equal(
		"Keyframes: quadro inicial",
		"from",
		animation.frames[0].selectors[0]
	)
	assert_equal(
		"Keyframes: quadro intermediário",
		"50%",
		animation.frames[1].selectors[0]
	)
	assert_equal(
		"Keyframes: quadro final",
		"to",
		animation.frames[2].selectors[0]
	)

	assert_equal(
		"Keyframes: busca pelo quadro inicial",
		"from",
		animation.get_frame("from").selectors[0]
	)
	assert_equal(
		"Keyframes: busca por quadro inexistente",
		null,
		animation.get_frame("25%")
	)


func _test_source_positions() -> void:
	var ast := _parse(""".button {
	background_color: #ff0000;
}""")

	if ast.get_rules().is_empty():
		assert_true(
			"Posições: regra encontrada",
			false,
			"Nenhuma regra foi produzida."
		)
		return

	var rule := ast.get_rules()[0]

	assert_equal(
		"Posições: linha inicial da regra",
		1,
		rule.line
	)
	assert_equal(
		"Posições: coluna inicial da regra",
		1,
		rule.column
	)

	if rule.declarations.is_empty():
		return

	var declaration := rule.declarations[0]

	assert_equal(
		"Posições: linha da declaração",
		2,
		declaration.line
	)
	assert_true(
		"Posições: intervalo da declaração é válido",
		declaration.end_offset > declaration.start_offset
	)


func _test_missing_colon() -> void:
	var ast := _parse("""
.button {
	background_color #ff0000;
}
""")

	assert_true(
		"Erro sintático: dois-pontos ausente",
		not ast.errors.is_empty(),
		"O parser deveria registrar a ausência de ':'."
	)

	if ast.errors.is_empty():
		return

	assert_true(
		"Erro sintático: mensagem do erro",
		str(ast.errors[0].message).contains(":"),
		"A mensagem deveria indicar o problema com a declaração."
	)


func _test_error_recovery() -> void:
	var ast := _parse("""
.button {
	invalid declaration;
	background_color: #00ff00;
}
.label {
	color: #ffffff;
}
""")

	assert_true(
		"Recuperação: erro original registrado",
		not ast.errors.is_empty()
	)
	assert_equal(
		"Recuperação: regras posteriores preservadas",
		2,
		ast.get_rules().size()
	)

	if ast.get_rules().size() != 2:
		return

	var first_rule := ast.get_rules()[0]

	assert_equal(
		"Recuperação: declaração válida após erro",
		1,
		first_rule.declarations.size()
	)

	if first_rule.declarations.is_empty():
		return

	assert_equal(
		"Recuperação: propriedade válida preservada",
		"background_color",
		first_rule.declarations[0].property_name
	)
	assert_equal(
		"Recuperação: valor válido preservado",
		"#00ff00",
		first_rule.declarations[0].value_text
	)


func _test_missing_closing_brace() -> void:
	var ast := _parse("""
.button {
	background_color: #ff0000;
""")

	assert_true(
		"Erro sintático: chave de fechamento ausente",
		not ast.errors.is_empty(),
		"O parser deveria detectar o bloco não fechado."
	)


func _test_unexpected_closing_brace() -> void:
	var ast := _parse("""
}
.button {
	background_color: #ff0000;
}
""")

	assert_true(
		"Erro sintático: chave inesperada registrada",
		not ast.errors.is_empty()
	)
	assert_equal(
		"Recuperação: regra após chave inesperada",
		1,
		ast.get_rules().size()
	)


func _test_unsupported_directive() -> void:
	var ast := _parse("""
@unknown something {
	value: 1;
}

.button {
	background_color: #ff0000;
}
""")

	assert_true(
		"Diretiva desconhecida: erro registrado",
		not ast.errors.is_empty()
	)
	assert_equal(
		"Diretiva desconhecida: regra seguinte preservada",
		1,
		ast.get_rules().size()
	)


func _parse(source: String) -> LCSSStyleSheetNode:
	var parser := LCSSSyntaxParser.new()
	return parser.parse(source)


func _get_value(
	rule: LCSSRuleNode,
	property_name: String
) -> String:
	var declaration := rule.get_declaration(property_name)

	if declaration == null:
		return ""

	return declaration.value_text



func _test_keyframes_with_multiple_frames() -> void:
	var parser := LCSSSyntaxParser.new()
	var ast := parser.parse("""
		@keyframes fade_in {
			from {
				padding: 0;
			}
			50% {
				padding: 8;
			}
			to {
				padding: 16;
			}
		}
""")

	assert_equal(
		"Keyframes: quantidade de animações",
		1,
		ast.get_keyframes().size()
	)

	if ast.get_keyframes().is_empty():
		return

	var keyframes := ast.get_keyframes()[0]

	assert_equal(
		"Keyframes: quantidade de frames",
		3,
		keyframes.frames.size()
	)

	assert_equal(
		"Keyframes: primeiro frame",
		"from",
		keyframes.frames[0].selectors[0]
	)

	assert_equal(
		"Keyframes: segundo frame",
		"50%",
		keyframes.frames[1].selectors[0]
	)

	assert_equal(
		"Keyframes: último frame",
		"to",
		keyframes.frames[2].selectors[0]
	)

	assert_equal(
		"Keyframes: nenhum erro sintático",
		0,
		ast.errors.size()
	)


func _test_keyframes_missing_frame_brace() -> void:
	var parser := LCSSSyntaxParser.new()
	var ast := parser.parse("""
		@keyframes fade_in {
			from
		}
		""")

	assert_true(
		"Keyframes: frame sem abertura de bloco gera erro",
		not ast.errors.is_empty()
	)



func _test_invalid_selector_generates_error() -> void:
	var parser := LCSSSyntaxParser.new()
	var ast := parser.parse("""
.button > .label {
	padding: 8;
}
""")

	assert_equal(
		"Seletor inválido: quantidade de regras preservada",
		1,
		ast.get_rules().size()
	)

	assert_false(
		"Seletor inválido: diagnóstico registrado",
		ast.errors.is_empty()
	)

	if not ast.errors.is_empty():
		assert_true(
			"Seletor inválido: mensagem identificável",
			ast.errors[0]["message"].contains("Seletor inválido")
		)

		assert_true(
			"Seletor inválido: posição identificada",
			ast.errors[0]["offset"] >= 0
		)


func _test_keyframes_are_not_validated_as_class_selectors() -> void:
	var parser := LCSSSyntaxParser.new()
	var ast := parser.parse("""
		@keyframes fade_in {
			from {
				padding: 0;
			}
			50% {
				padding: 8;
			}
			to {
				padding: 16;
			}
		}
	""")

	assert_equal(
		"Keyframes: frames não geram erros de seletores de classe",
		0,
		ast.errors.size()
	)



func _test_unknown_property_generates_semantic_error() -> void:
	var ast := _parse("""
.button {
	unknown_property: 10;
	background_color: #ff0000;
}
""")

	assert_equal(
		"Validação semântica: regra preservada",
		1,
		ast.get_rules().size()
	)

	assert_equal(
		"Validação semântica: uma propriedade desconhecida gera um erro",
		1,
		ast.errors.size()
	)

	if ast.errors.is_empty():
		return

	assert_true(
		"Validação semântica: propriedade desconhecida identificada",
		str(ast.errors[0]["message"]).contains("Unknown property")
	)

	var declarations := ast.get_rules()[0].declarations

	assert_equal(
		"Validação semântica: declaração válida preservada",
		2,
		declarations.size()
	)


func _test_invalid_option_generates_semantic_error() -> void:
	var ast := _parse("""
.button {
	display: grid;
}
""")

	assert_equal(
		"Validação semântica: regra preservada com opção inválida",
		1,
		ast.get_rules().size()
	)

	assert_equal(
		"Validação semântica: uma opção inválida gera um erro",
		1,
		ast.errors.size()
	)

	if ast.errors.is_empty():
		return

	assert_true(
		"Validação semântica: valor inválido identificado",
		str(ast.errors[0]["message"]).contains("Invalid value")
	)

	assert_true(
		"Validação semântica: valor inválido informado",
		str(ast.errors[0]["message"]).contains("grid")
	)


func _test_semantic_error_has_source_position() -> void:
	var source := ".button {\n\tunknown_property: 10;\n}"
	var ast := _parse(source)

	if ast.errors.is_empty():
		assert_true(
			"Validação semântica: diagnóstico produzido",
			false,
			"Nenhum diagnóstico foi produzido."
		)
		return

	var error: Dictionary = ast.errors[0]
	var expected_offset := source.find("unknown_property")

	assert_equal(
		"Validação semântica: linha correta",
		2,
		error["line"]
	)

	assert_equal(
		"Validação semântica: coluna inicial correta",
		2,
		error["column"]
	)

	assert_equal(
		"Validação semântica: offset inicial correto",
		expected_offset,
		error["offset"]
	)
