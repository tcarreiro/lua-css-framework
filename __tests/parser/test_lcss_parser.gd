extends LCSSUnitTestSuite


func run_tests() -> void:
	_test_simple_rule()
	_test_multiple_selectors()
	_test_value_conversion()
	_test_texture_and_url_functions()
	_test_keyframes()
	_test_custom_properties()
	_test_syntax_error_preserves_valid_rules()


func _test_simple_rule() -> void:
	var stylesheet := _parse_stylesheet("""
		.button {
			background_color: #FF0000;
			padding: 12;
		}
		""")

	assert_true(
		"Simple rule: one rule is generated",
		stylesheet.rules.size() == 1
	)

	var rule: LCSSRule = stylesheet.rules[0]

	assert_true(
		"Simple rule: selector is preserved",
		rule.selector != null and rule.selector.parts.size() > 0
	)

	assert_true(
		"Simple rule: string property is preserved",
		rule.properties.get(&"background_color") == "#FF0000"
	)

	assert_true(
		"Simple rule: integer property is converted",
		rule.properties.get(&"padding") == 12
	)


func _test_multiple_selectors() -> void:
	var stylesheet := _parse_stylesheet("""
.button, .primary {
	padding: 16;
}
""")

	assert_true(
		"Multiple selectors: one rule is generated per selector",
		stylesheet.rules.size() == 2
	)

	for rule: LCSSRule in stylesheet.rules:
		assert_true(
			"Multiple selectors: declarations are copied to every rule",
			rule.properties.get(&"padding") == 16
		)


func _test_value_conversion() -> void:
	var stylesheet := _parse_stylesheet("""
.values {
	integer_value: 12;
	float_value: 1.5;
	milliseconds_value: 250ms;
	seconds_value: 1.5s;
	array_value: [1, 2.5, 3];
	vector_value: 1 2 3;
	quoted_value: "hello world";
}
""")

	assert_true(
		"Value conversion: one rule is generated",
		stylesheet.rules.size() == 1
	)

	var properties: Dictionary = stylesheet.rules[0].properties

	assert_true(
		"Value conversion: integer",
		properties.get(&"integer_value") == 12
	)

	assert_true(
		"Value conversion: float",
		is_equal_approx(float(properties.get(&"float_value", -1.0)), 1.5)
	)

	assert_true(
		"Value conversion: milliseconds become seconds",
		is_equal_approx(float(properties.get(&"milliseconds_value", -1.0)), 0.25)
	)

	assert_true(
		"Value conversion: seconds remain seconds",
		is_equal_approx(float(properties.get(&"seconds_value", -1.0)), 1.5)
	)

	assert_true(
		"Value conversion: array values are converted",
		properties.get(&"array_value") == [1, 2.5, 3]
	)

	assert_true(
		"Value conversion: space-separated numbers become an array",
		properties.get(&"vector_value") == [1, 2, 3]
	)

	assert_true(
		"Value conversion: standalone quoted strings preserve legacy behavior",
		properties.get(&"quoted_value") == "\"hello world\""
	)


func _test_texture_and_url_functions() -> void:
	var stylesheet := _parse_stylesheet("""
.resources {
	texture_value: texture("res://test.png");
	url_value: url("res://test.png");
}
""")

	assert_true(
		"Resource functions: one rule is generated",
		stylesheet.rules.size() == 1
	)

	var properties: Dictionary = stylesheet.rules[0].properties

	assert_true(
		"Resource functions: texture() returns the path",
		properties.get(&"texture_value") == "res://test.png"
	)

	assert_true(
		"Resource functions: url() returns the path",
		properties.get(&"url_value") == "res://test.png"
	)


func _test_keyframes() -> void:
	var stylesheet := _parse_stylesheet("""
@keyframes fade_in {
	from {
		opacity: 0;
	}
	50% {
		opacity: 0.5;
	}
	to {
		opacity: 1;
	}
}
""")

	assert_true(
		"Keyframes: no regular rules are generated",
		stylesheet.rules.is_empty()
	)

	assert_true(
		"Keyframes: animation is registered",
		stylesheet.keyframes.has(&"fade_in")
	)

	if not stylesheet.keyframes.has(&"fade_in"):
		return

	var keyframes: LCSSKeyframes = stylesheet.keyframes[&"fade_in"]
	var frames := keyframes.frames_for(&"opacity")

	assert_true(
		"Keyframes: all three frames are generated",
		frames.size() == 3
	)

	if frames.size() != 3:
		return

	assert_true(
		"Keyframes: from maps to offset 0",
		is_equal_approx(float(frames[0]["offset"]), 0.0)
	)

	assert_true(
		"Keyframes: 50% maps to offset 0.5",
		is_equal_approx(float(frames[1]["offset"]), 0.5)
	)

	assert_true(
		"Keyframes: to maps to offset 1",
		is_equal_approx(float(frames[2]["offset"]), 1.0)
	)

	assert_true(
		"Keyframes: frame values are preserved",
		frames[0]["value"] == 0
		and is_equal_approx(float(frames[1]["value"]), 0.5)
		and frames[2]["value"] == 1
	)


func _test_custom_properties() -> void:
	var stylesheet := _parse_stylesheet("""
.my_component {
	panel1_background_color: #FF0000;
	panel2_background_color: #00FF00;
	header_panel_background_color: #0000FF;
}
""")

	assert_true(
		"Custom properties: one rule is generated",
		stylesheet.rules.size() == 1
	)

	if stylesheet.rules.is_empty():
		return

	var properties: Dictionary = stylesheet.rules[0].properties

	assert_true(
		"Custom properties: panel1 property is preserved",
		properties.get(&"panel1_background_color") == "#FF0000"
	)

	assert_true(
		"Custom properties: panel2 property is preserved",
		properties.get(&"panel2_background_color") == "#00FF00"
	)

	assert_true(
		"Custom properties: compound prefix is preserved",
		properties.get(&"header_panel_background_color") == "#0000FF"
	)


func _test_syntax_error_preserves_valid_rules() -> void:
	var source := """
	.valid {
		opacity: 1;
	}

	.broken {
		opacity: 2;
	"""

	var ast := LCSSSyntaxParser.new().parse(source)

	assert_true(
		"Syntax errors: malformed source produces diagnostics",
		not ast.errors.is_empty()
	)

	var stylesheet := _parse_stylesheet(source)

	assert_true(
		"Syntax errors: valid rules before the error are preserved",
		not stylesheet.rules.is_empty()
	)

	if not stylesheet.rules.is_empty():
		assert_true(
			"Syntax errors: the first valid declaration is preserved",
			stylesheet.rules[0].properties.get(&"opacity") == 1
		)


func _parse_stylesheet(source: String) -> LCSSStyleSheet:
	return LCSSParser.new().parse(source)
