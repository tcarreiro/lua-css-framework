@tool
extends EditorPlugin

const AUTOLOAD_LUA_UI_BRIDGE_NAME := "LuaUiBridge"
const AUTOLOAD_LUA_UI_BRIDGE_PATH := "res://addons/lua-modder/UI/lua_ui_bridge.gd"

const AUTOLOAD_LUA_EVENT_BRIDGE_NAME := "LuaUiEventBridge"
const AUTOLOAD_LUA_EVENT_BRIDGE_PATH := "res://addons/lua-modder/UI/lua_ui_event_bridge.gd"

const AUTOLOAD_LUA_CONTENT_NAME := "LuaContentBridge"
const AUTOLOAD_LUA_CONTENT_PATH := "res://addons/lua-modder/Content/lua_content_bridge.gd"


func _enter_tree() -> void:
	if not _check_dependencies():
		return

	add_autoload_singleton(AUTOLOAD_LUA_UI_BRIDGE_NAME, AUTOLOAD_LUA_UI_BRIDGE_PATH)
	add_autoload_singleton(AUTOLOAD_LUA_EVENT_BRIDGE_NAME, AUTOLOAD_LUA_EVENT_BRIDGE_PATH)
	add_autoload_singleton(AUTOLOAD_LUA_CONTENT_NAME, AUTOLOAD_LUA_CONTENT_PATH)


func _exit_tree() -> void:
	if ClassDB.class_exists("LuaState"):
		remove_autoload_singleton(AUTOLOAD_LUA_UI_BRIDGE_NAME)
		remove_autoload_singleton(AUTOLOAD_LUA_EVENT_BRIDGE_NAME)
		remove_autoload_singleton(AUTOLOAD_LUA_CONTENT_NAME)


func _check_dependencies() -> bool:
	if not ClassDB.class_exists("LuaState"):
		push_error(
			"[Lua UI Builder] Dependência ausente: o addon 'lua-gdextension' "
			+ "precisa estar instalado e ativado antes deste addon. "
			+ "Veja: https://github.com/gilzoide/lua-gdextension"
		)
		return false
		
	if not ClassDB.class_exists("GDSS"):
		push_error(
			"[GDSS] Dependência ausente: o addon 'gdss' "
			+ "precisa estar instalado e ativado antes deste addon. "
			+ "Veja: https://github.com/cruglet/gdss"
		)
		return false
	return true
