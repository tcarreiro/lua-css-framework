extends Control

@export var test_paths: Array[String] = ["res://__tests"]

@onready var _run_button: Button = %RunButton
@onready var _output: RichTextLabel = %Output
@onready var _summary: Label = %Summary


func _ready() -> void:
	_build_ui()
	_run_button.pressed.connect(_run_all_tests)


func _build_ui() -> void:
	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 10)
	add_child(layout)

	var title := Label.new()
	title.text = "LCSS Test Runner"
	title.add_theme_font_size_override("font_size", 24)
	layout.add_child(title)

	var run_button := Button.new()
	run_button.name = "RunButton"
	run_button.unique_name_in_owner = true
	run_button.text = "Executar testes"
	layout.add_child(run_button)

	var summary := Label.new()
	summary.name = "Summary"
	summary.unique_name_in_owner = true
	summary.text = "Pronto para executar."
	layout.add_child(summary)

	var output := RichTextLabel.new()
	output.name = "Output"
	output.unique_name_in_owner = true
	output.bbcode_enabled = true
	output.scroll_following = true
	output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(output)

	_run_button = run_button
	_summary = summary
	_output = output


func _run_all_tests() -> void:
	_run_button.disabled = true
	_output.clear()
	_summary.text = "Executando..."

	var paths: Array[String] = []
	for path in test_paths:
		_collect_test_paths(path, paths)

	paths.sort()

	var total_passed := 0
	var total_failed := 0
	var suites_run := 0

	if paths.is_empty():
		_output.append_text("[color=orange]Nenhum arquivo test_*.gd encontrado.[/color]\n")

	for path in paths:
		var test_script := load(path) as Script

		if test_script == null:
			total_failed += 1
			_output.append_text("[color=red]ERRO: Não foi possível carregar %s[/color]\n" % path)
			continue

		var suite := test_script.new() as LCSSUnitTestSuite

		if suite == null:
			total_failed += 1
			_output.append_text("[color=red]ERRO: %s não herda LCSSUnitTestSuite.[/color]\n" % path)
			continue

		suites_run += 1
		_output.append_text("\n[b]%s[/b]\n" % path)

		suite.test_reported.connect(_on_test_reported)

		suite.run_tests()

		total_passed += suite.passed_count
		total_failed += suite.failed_count

		suite.test_reported.disconnect(_on_test_reported)

	_output.append_text("\n[b]Resultado final[/b]\n")
	_output.append_text("Suítes executadas: %d\n" % suites_run)
	_output.append_text("[color=green]Passaram: %d[/color]\n" % total_passed)
	_output.append_text("[color=red]Falharam: %d[/color]\n" % total_failed)

	_summary.text = "%d passaram | %d falharam" % [total_passed, total_failed]
	_run_button.disabled = false


func _on_test_reported(
	passed: bool,
	test_name: String,
	message: String
) -> void:
	if passed:
		_output.append_text("[color=green]PASS[/color] %s\n" % test_name)
	else:
		_output.append_text("[color=red]FAIL[/color] %s: %s\n" % [test_name, message])


func _collect_test_paths(path: String, result: Array[String]) -> void:
	if path.ends_with(".gd"):
		if path.get_file().begins_with("test_") and not result.has(path):
			result.append(path)
		return

	var directory := DirAccess.open(path)
	if directory == null:
		push_warning("Não foi possível abrir o caminho de testes: %s" % path)
		return

	for file_name in directory.get_files():
		if file_name.begins_with("test_") and file_name.ends_with(".gd"):
			var file_path := path.path_join(file_name)
			if not result.has(file_path):
				result.append(file_path)

	for directory_name in directory.get_directories():
		_collect_test_paths(path.path_join(directory_name), result)
