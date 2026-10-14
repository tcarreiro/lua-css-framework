extends LCSSUnitTestSuite

var validator := LCSSSemanticValidator.new()

func run_tests() -> void:
	#reset_results()
	_test_valid_properties()
	_test_invalid_properties()
	_test_valid_options()
	_test_invalid_options()
	_test_whitespace()


func _test_valid_properties() -> void:
	assert_true(
		"Known property with arbitrary value",
		validator.validate_declaration("background_color", "not_a_color").is_empty()
	)

	assert_true(
		"Known property without options",
		validator.validate_declaration("gap", "some_value").is_empty()
	)

	assert_true(
		"Base property",
		validator.validate_declaration("visible", "anything").is_empty()
	)


func _test_invalid_properties() -> void:
	assert_false(
		"Unknown property",
		validator.validate_declaration("unknown_property", "value").is_empty()
	)

	assert_false(
		"Unknown property with valid-looking value",
		validator.validate_declaration("background_colour", "#FFFFFF").is_empty()
	)


func _test_valid_options() -> void:
	assert_true(
		"Valid display option",
		validator.validate_declaration("display", "block").is_empty()
	)

	assert_true(
		"Another valid display option",
		validator.validate_declaration("display", "flex").is_empty()
	)

	assert_true(
		"Valid direction option",
		validator.validate_declaration("direction", "vertical").is_empty()
	)

	assert_true(
		"Valid type option",
		validator.validate_declaration("type", "number").is_empty()
	)


func _test_invalid_options() -> void:
	assert_false(
		"Invalid display option",
		validator.validate_declaration("display", "grid").is_empty()
	)

	assert_false(
		"Invalid direction option",
		validator.validate_declaration("direction", "diagonal").is_empty()
	)

	assert_false(
		"Invalid input_type option",
		validator.validate_declaration("input_type", "password").is_empty()
	)


func _test_whitespace() -> void:
	assert_true(
		"Whitespace around valid option",
		validator.validate_declaration("display", "  flex  ").is_empty()
	)

	assert_false(
		"Whitespace does not make invalid option valid",
		validator.validate_declaration("display", "  grid  ").is_empty()
	)
