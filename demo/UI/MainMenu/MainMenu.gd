extends Control

var player_state := {"name": ""}
var _menu_instance: Control
@onready var screen_layer: CanvasLayer = %ScreenLayer


func _ready() -> void:
	LuaUi.set_root(self)
	LuaUi.load_file("res://demo/UI/MainMenu/main_menu.lua")
	LuaUi.load_file("res://demo/UI/MainMenu/profile.lua")
	_mount_menu()


func _mount_menu() -> void:
	if _menu_instance:
		_menu_instance.dispose()

	player_state["on_change"] = Callable(self, "_on_menu_state_changed")

	var el := ComponentRegistry.make_element("MainMenu", player_state)
	_menu_instance = ComponentRegistry.instantiate(el)
	screen_layer.add_child(_menu_instance)


func _on_menu_state_changed(new_state: Variant) -> void:
	player_state = LuaHelper.normalize_lua(new_state)
	_mount_menu()   # dispose do antigo + mount do novo, com o dado fresco
