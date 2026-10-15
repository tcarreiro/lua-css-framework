@tool
extends EditorPlugin

var lcss_highlighter: LCSSSyntaxHighlighter
var _active_lcss_code_edit: CodeEdit
var _connected_code_edits: Dictionary = {}

const AUTOLOAD_COMPONENT_REGISTRY_NAME := "ComponentRegistry"
const AUTOLOAD_COMPONENT_REGISTRY_PATH := "res://addons/lua-modder/UI/Registries/ComponentRegistry.gd"

const AUTOLOAD_LUA_UI_NAME := "LuaUi"
const AUTOLOAD_LUA_UI_PATH := "res://addons/lua-modder/UI/LuaUi.gd"

const AUTOLOAD_LUA_BRIDGE_NAME := "LuaBridgeRegistry"
const AUTOLOAD_LUA_BRIDGE_PATH := "res://addons/lua-modder/LuaBridgeRegistry.gd"

func _get_recognized_extensions() -> Array:
	return ["lcss"]


func _setup_extension_recognition():
	var settings = EditorInterface.get_editor_settings()
	var ext: PackedStringArray = settings.get_setting("docks/filesystem/textfile_extensions").split(",")
	for recognized_extension in _get_recognized_extensions():
		if not ext.has(recognized_extension):
			ext.append(recognized_extension)
	settings.set("docks/filesystem/textfile_extensions", ",".join(ext))


func _remove_recognized_extensions():
	var settings = EditorInterface.get_editor_settings()
	var ext: PackedStringArray  = settings.get_setting("docks/filesystem/textfile_extensions").split(",")
	for recognized_extension in _get_recognized_extensions():
		ext.erase(recognized_extension)
	settings.set("docks/filesystem/textfile_extensions", ",".join(ext))



func _enter_tree() -> void:
	if not _check_dependencies():
		return

	_setup_extension_recognition()
	_setup_editor()
	
	add_autoload_singleton(AUTOLOAD_COMPONENT_REGISTRY_NAME, AUTOLOAD_COMPONENT_REGISTRY_PATH)
	add_autoload_singleton(AUTOLOAD_LUA_UI_NAME, AUTOLOAD_LUA_UI_PATH)
	add_autoload_singleton(AUTOLOAD_LUA_BRIDGE_NAME, AUTOLOAD_LUA_BRIDGE_PATH)


func _exit_tree() -> void:
	if ClassDB.class_exists("LuaState"):
		remove_autoload_singleton(AUTOLOAD_COMPONENT_REGISTRY_NAME)
		remove_autoload_singleton(AUTOLOAD_LUA_UI_NAME)
		remove_autoload_singleton(AUTOLOAD_LUA_BRIDGE_NAME)
	
	if is_instance_valid(lcss_highlighter):
		EditorInterface.get_script_editor().unregister_syntax_highlighter(lcss_highlighter)
	
	_remove_recognized_extensions()


func _check_dependencies() -> bool:
	if not ClassDB.class_exists("LuaState"):
		push_error(
			"[Lua UI Builder] Dependência ausente: o addon 'lua-gdextension' "
			+ "precisa estar instalado e ativado antes deste addon. "
			+ "Veja: https://github.com/gilzoide/lua-gdextension"
		)
		return false
	return true

func _setup_editor() -> void:
	var script_editor := EditorInterface.get_script_editor()
	print(script_editor, "|", script_editor.get_current_script())
	lcss_highlighter = LCSSSyntaxHighlighter.new()
	EditorInterface.get_script_editor().register_syntax_highlighter(lcss_highlighter)



func _process(_delta: float) -> void:
	var script_editor := EditorInterface.get_script_editor()
	#print(script_editor, "|", script_editor.get_current_editor().get_base_editor())
	var current_editor = script_editor.get_current_editor()
	#var _code_edit = (script_editor.get_current_editor().get_base_editor() as CodeEdit).text
	#print(script_editor.get_current_script())
	#print(_code_edit)

	if current_editor == null:
		_active_lcss_code_edit = null
		return

	var code_edit := current_editor.get_base_editor() as CodeEdit
	if code_edit == null:
		_active_lcss_code_edit = null
		return

	_active_lcss_code_edit = code_edit

	var instance_id := code_edit.get_instance_id()
	if _connected_code_edits.has(instance_id):
		return

	_connected_code_edits[instance_id] = true
	code_edit.code_completion_enabled = true

	code_edit.code_completion_requested.connect(
		_on_lcss_code_completion_requested.bind(code_edit)
	)
	code_edit.text_changed.connect(
		_on_lcss_text_changed.bind(code_edit)
	)


func _on_lcss_text_changed(code_edit: CodeEdit) -> void:
	if code_edit != _active_lcss_code_edit:
		return

	var prefix := _get_current_word(code_edit)
	if not prefix.is_empty():
		code_edit.request_code_completion()


func _on_lcss_code_completion_requested(code_edit: CodeEdit) -> void:
	if code_edit != _active_lcss_code_edit:
		return

	var prefix := _get_current_word(code_edit)
	var catalog: Dictionary = ComponentProps._catalog()

	for property_name in catalog:
		var property_text := str(property_name)

		if prefix.is_empty() or property_text.begins_with(prefix):
			code_edit.add_code_completion_option(
				CodeEdit.KIND_PLAIN_TEXT,
				property_text,
				property_text
			)

	code_edit.update_code_completion_options(true)


func _get_current_word(code_edit: CodeEdit) -> String:
	var line := code_edit.get_line(code_edit.get_caret_line())
	var column := code_edit.get_caret_column()
	var start := column

	while start > 0:
		var character := line.substr(start - 1, 1)
		if not character.is_valid_identifier():
			break
		start -= 1

	return line.substr(start, column - start)
