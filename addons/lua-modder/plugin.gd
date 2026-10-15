@tool
extends EditorPlugin

const LCSS_EDITOR_SCENE = preload("uid://bh4sv3ta53fmk")

var lcss_highlighter: LCSSSyntaxHighlighter

static var _inst: EditorPlugin

var lcss_editor: LCSSEditor
var lcss_dock: LCSSDock
var _loading_scene: bool = false

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
	
	if is_instance_valid(lcss_dock):
		remove_dock(lcss_dock)
		lcss_dock.queue_free()
		lcss_dock = null
		lcss_editor = null
	
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
	lcss_editor = LCSS_EDITOR_SCENE.instantiate()
	
	lcss_highlighter = LCSSSyntaxHighlighter.new()
	EditorInterface.get_script_editor().register_syntax_highlighter(lcss_highlighter)
	lcss_dock = LCSSDock.new()
	lcss_dock.set_editor(lcss_editor)
	add_dock(lcss_dock)


















#
