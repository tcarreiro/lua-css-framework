class_name LCSSRegistry extends RefCounted
# Registry of LCSSStyleSheets

var _stylesheets: Dictionary[StringName, LCSSStyleSheet] = {}

func register_file(path: String) -> LCSSStyleSheet:
	if not FileAccess.file_exists(path):
		push_error("[LCSSRegistry] - File '%s' not found." % [path])
		return null

	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("[LCSSRegistry] - Invalid file at '%s'." % [path])
		return null

	var last_slash_index = path.rfind("/")
	var file_name = path.right(path.length() - last_slash_index).split(".")[0]
	if file_name == null or file_name == "":
		push_error("[LCSSRegistry] - Invalid filename at '%s'."%[path])
		
	return register(file_name, file.get_as_text())


func register(stylesheet_name: StringName, text: String) -> LCSSStyleSheet:
	var stylesheet := LCSSParser.new().parse(text)
	return register_stylesheet(stylesheet_name, stylesheet)


func register_stylesheet(stylesheet_name: StringName, stylesheet: LCSSStyleSheet) -> LCSSStyleSheet:
	if stylesheet == null:
		return
	if _stylesheets.has(stylesheet_name):
		push_warning("[LCSSRegistry] - Stylesheet '%s' already registered. Overwriting it."%[stylesheet_name])
	_stylesheets[stylesheet_name] = stylesheet
	return stylesheet


func unregister(stylesheet: LCSSStyleSheet) -> void:
	var key = _stylesheets.find_key(stylesheet)
	_stylesheets.erase(key)


func clear() -> void:
	_stylesheets.clear()


func get_stylesheets() -> Array[LCSSStyleSheet]:
	return _stylesheets.values().duplicate()


func get_stylesheet_count() -> int:
	return _stylesheets.size()


func find_keyframes(anim_name: StringName) -> LCSSKeyframes:
	for i in range(_stylesheets.values().size() - 1, -1, -1):
		var found: Variant = _stylesheets.values()[i].keyframes.get(String(anim_name))
		if found != null:
			return found
	return null
	
