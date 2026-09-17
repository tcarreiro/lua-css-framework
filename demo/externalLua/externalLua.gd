extends Node2D

var _lua: LuaState
var _lua_handler_id := -1

const ALTERNATE_THEME = preload("uid://dnw0853m3kqpi")

func _ready() -> void:
	LuaUiBridge.register_theme("alternate", ALTERNATE_THEME)

	var lua := LuaUiBridge.get_or_create_state()
	LuaUiEventBridge.register_into(lua)
	LuaUiEventBridge.lua_event.connect(_on_lua_event)

	var result = lua.do_file("res://demo/externalLua/professional_window.lua")
	if result is LuaError:
		push_error("[Teste] Erro ao carregar mod Lua: %s" % result)
		return

	_lua = lua

	var open_btn := Button.new()
	open_btn.text = "Abrir janela profissional"
	open_btn.position = Vector2(20, 20)
	add_child(open_btn)
	open_btn.pressed.connect(_on_open_pressed.bind(open_btn))


func _on_open_pressed(btn: Control) -> void:
	if _lua_handler_id != -1:
		LuaUiBridge.close(_lua_handler_id)
		_lua_handler_id = -1
		return

	var initial_state = {
		"title": "Editor de Personagem",
		"first_name": "",
		"last_name": "",
		"gender": "m",
		"textures": {
			"head": "res://demo/assets/images/char_head.png",
			"torso": "res://demo/assets/images/char_torso.png",
			"legs": "res://demo/assets/images/char_legs.png",
		}
	}

	var raw_def = LuaHelpers.call_by_name(_lua, "onOpenWindow", [initial_state])
	_lua_handler_id = LuaUiBridge.open_at(_lua, raw_def, btn)


func _on_lua_event(event_name: String, data) -> void:
	match event_name:
		"window_closed":
			_lua_handler_id = -1
		"state_saved":
			print("Estado salvo: ", data)


func _create_alternate_theme() -> Theme:
	var theme := Theme.new()

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.18)
	theme.set_stylebox("panel", "PanelContainer", panel_style)

	theme.set_color("font_color", "Label", Color(0.95, 0.95, 0.95))

	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color(0.25, 0.25, 0.3)
	button_style.corner_radius_top_left = 4
	button_style.corner_radius_top_right = 4
	button_style.corner_radius_bottom_left = 4
	button_style.corner_radius_bottom_right = 4
	theme.set_stylebox("normal", "Button", button_style)

	# Variação usada só na section de edição de personagem (fundo mais escuro).
	var char_edit_bg := StyleBoxFlat.new()
	char_edit_bg.bg_color = Color(0.08, 0.08, 0.1)
	char_edit_bg.corner_radius_top_left = 6
	char_edit_bg.corner_radius_top_right = 6
	char_edit_bg.corner_radius_bottom_left = 6
	char_edit_bg.corner_radius_bottom_right = 6
	theme.set_stylebox("panel", "char_edit_bg", char_edit_bg)
	theme.set_type_variation("char_edit_bg", "PanelContainer")

	return theme
