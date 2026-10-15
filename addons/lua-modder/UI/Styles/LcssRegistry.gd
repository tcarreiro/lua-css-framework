class_name LCSSRegistry extends RefCounted

var _stylesheets: Array[LCSSStyleSheet] = []


func register(text: String) -> LCSSStyleSheet:
	var stylesheet := LCSSParser.new().parse(text)
	_stylesheets.append(stylesheet)
	return stylesheet


func register_file(path: String) -> LCSSStyleSheet:
	if not FileAccess.file_exists(path):
		push_error("[LCSSRegistry] arquivo não encontrado: '%s'" % path)
		return null

	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("[LCSSRegistry] não foi possível abrir o arquivo: '%s'" % path)
		return null

	return register(file.get_as_text())


func register_stylesheet(stylesheet: LCSSStyleSheet) -> void:
	if stylesheet == null:
		return

	_stylesheets.append(stylesheet)


func unregister(stylesheet: LCSSStyleSheet) -> void:
	_stylesheets.erase(stylesheet)


func clear() -> void:
	_stylesheets.clear()


func get_stylesheets() -> Array[LCSSStyleSheet]:
	return _stylesheets.duplicate()


func get_stylesheet_count() -> int:
	return _stylesheets.size()


func find_keyframes(anim_name: StringName) -> LCSSKeyframes:
	for i in range(_stylesheets.size() - 1, -1, -1):
		var found: Variant = _stylesheets[i].keyframes.get(String(anim_name))
		if found != null:
			return found
	return null
