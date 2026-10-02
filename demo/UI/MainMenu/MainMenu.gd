extends Control

var player_state := {"name": ""}
var _menu_instance: Control
@onready var circular_container: CircularContainer = %CircularContainer
@onready var button: Button = %Button
@onready var texture_rect: TextureRect = %TextureRect


func _ready() -> void:
	LuaUi.set_root(self)
	LuaUi.load_lcss("res://addons/lua-modder/Styles/global.lcss")
	LuaUi.load_file("res://demo/UI/MainMenu/test_div.lua")
	LuaUi.load_file("res://demo/UI/MainMenu/profile.lua")
	button.pressed.connect(_add_child)
	_mount_menu()


func _add_child() -> void:
	var ch = texture_rect.duplicate()
	ch.visible = true
	circular_container.add_child(ch)
	circular_container.update_angle()
	ch.gui_input.connect(_on_click.bind(ch))


func _mount_menu() -> void:
	if _menu_instance:
		_menu_instance.dispose()

	player_state["on_change"] = Callable(self, "_on_menu_state_changed")

	var el := ComponentRegistry.make_element("TestScreen", player_state)
	_menu_instance = ComponentRegistry.instantiate(el)
	add_child(_menu_instance)


func _on_menu_state_changed(new_state: Variant) -> void:
	player_state = LuaHelper.normalize_lua(new_state)
	_mount_menu()   # dispose do antigo + mount do novo, com o dado fresco


func _on_click(event: InputEvent, node: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		circular_container.remove_child(node)
		circular_container.update_angle()
