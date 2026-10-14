
extends LCSSUnitTestSuite


var validator := LCSSSelectorValidator.new()


func run_tests() -> void:
	reset_results()

	_test_valid_selectors()
	_test_invalid_selectors()
	_test_custom_states()
	_test_selector_lists()


func _test_valid_selectors() -> void:
	assert_true(
		"Seletor de classe",
		validator.validate_selector(".button").is_empty()
	)

	assert_true(
		"Classe com estado",
		validator.validate_selector(".button:hover").is_empty()
	)

	assert_true(
		"Classe com múltiplos estados",
		validator.validate_selector(".button:hover:focus").is_empty()
	)

	assert_true(
		"Seletor descendente",
		validator.validate_selector(".card .button").is_empty()
	)

	assert_true(
		"Seletor descendente com estados",
		validator.validate_selector(".card:hover .button:pressed").is_empty()
	)

	assert_true(
		"Nome de classe com underscore",
		validator.validate_selector(".main_menu").is_empty()
	)

	assert_true(
		"Nome de classe com hífen",
		validator.validate_selector(".main-menu").is_empty()
	)

	assert_true(
		"Espaços extras",
		validator.validate_selector("  .card   .button  ").is_empty()
	)


func _test_invalid_selectors() -> void:
	assert_false(
		"Seletor vazio",
		validator.validate_selector("").is_empty()
	)

	assert_false(
		"Seletor sem ponto",
		validator.validate_selector("button").is_empty()
	)

	assert_false(
		"Estado sem classe",
		validator.validate_selector(":hover").is_empty()
	)

	assert_false(
		"Classe sem nome",
		validator.validate_selector(".").is_empty()
	)

	assert_false(
		"Estado sem nome",
		validator.validate_selector(".button:").is_empty()
	)

	assert_false(
		"Dois pontos consecutivos",
		validator.validate_selector(".button..label").is_empty()
	)

	assert_false(
		"Combinador de filho direto não suportado",
		validator.validate_selector(".button > .label").is_empty()
	)

	assert_false(
		"Estado separado da classe",
		validator.validate_selector(".button :hover").is_empty()
	)

	assert_false(
		"Nome de classe iniciado por número",
		validator.validate_selector(".123button").is_empty()
	)


func _test_custom_states() -> void:
	assert_true(
		"Estado personalizado",
		validator.validate_selector(".button:loading").is_empty()
	)

	assert_true(
		"Estado personalizado com underscore",
		validator.validate_selector(".button:is_loading").is_empty()
	)

	assert_true(
		"Estado personalizado com hífen",
		validator.validate_selector(".button:drag-over").is_empty()
	)


func _test_selector_lists() -> void:
	var selectors := PackedStringArray([
		".button",
		".button:hover",
		".card .button"
	])

	assert_true(
		"Lista de seletores válidos",
		validator.validate_selectors(selectors).is_empty()
	)

	var invalid_selectors := PackedStringArray([
		".button",
		".",
		".card > .button"
	])

	var errors := validator.validate_selectors(invalid_selectors)

	assert_equal(
		"Lista de seletores inválidos",
		2,
		errors.size()
	)

	if errors.size() == 2:
		assert_equal(
			"Índice do primeiro seletor inválido",
			1,
			errors[0]["selector_index"]
		)

		assert_equal(
			"Índice do segundo seletor inválido",
			2,
			errors[1]["selector_index"]
		)
