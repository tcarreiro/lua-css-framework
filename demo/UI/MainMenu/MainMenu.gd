extends Control

var player_state := {"name": ""}
var _menu_instance: Control
@onready var screen_layer: CanvasLayer = %ScreenLayer
@onready var body: Control = %Body


func _ready() -> void:
	LuaUi.set_root(self)
	LuaUi.load_file("res://demo/UI/MainMenu/div.lua")
	LuaUi.load_file("res://demo/UI/MainMenu/profile.lua")
	_mount_menu()


func _mount_menu() -> void:
	var _lb = Label.new()
	_lb.text = "A"
	var _lb2 = Label.new()
	_lb2.text = "B"
	var _bc = BoxContainer.new()
	_bc.add_child(_lb)
	_bc.add_child(_lb2)
	var _lb3 = Label.new()
	_lb3.text = "C"
	var _bc2 = BoxContainer.new()
	_bc2.add_child(_lb3)
	body.add_child(_bc)
	body.add_child(_bc2)
	#if _menu_instance:
		#_menu_instance.dispose()
#
	#player_state["on_change"] = Callable(self, "_on_menu_state_changed")
#
	#var el := ComponentRegistry.make_element("MainMenu", player_state)
	#_menu_instance = ComponentRegistry.instantiate(el)
	#screen_layer.add_child(_menu_instance)


func _on_menu_state_changed(new_state: Variant) -> void:
	player_state = LuaHelper.normalize_lua(new_state)
	_mount_menu()   # dispose do antigo + mount do novo, com o dado fresco
