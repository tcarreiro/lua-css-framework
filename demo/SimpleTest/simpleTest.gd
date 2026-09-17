extends Node2D

@export var lua_file: Resource
@onready var button: Button = $Button
@onready var label: Label = $Label

var _lua: LuaState
var _lua_handler_id := -1
var label_state = {}

const CLICK_1 = preload("uid://58qresn5blvp")
const SWITCH_2 = preload("uid://c18lo7uas6cea")

const ALTERNATE_THEME = preload("uid://dnw0853m3kqpi")
const DEFAULT_THEME = preload("uid://cr631ev7ippgd")

func _ready() -> void:
	LuaUiBridge.register_theme("default", DEFAULT_THEME)
	LuaUiBridge.register_theme("alternate", ALTERNATE_THEME)
	LuaUiBridge.register_theme("dark_blue", _create_test_theme())
	LuaUiBridge.register_animation("soft_pulse", _create_test_pulse())
	LuaUiBridge.register_animation("press_bounce", _create_test_bounce())

	LuaUiBridge.register_sound("ui_hover", CLICK_1)
	LuaUiBridge.register_sound("ui_click", SWITCH_2)

	var lua := LuaUiBridge.get_or_create_state()

	if not lua_file:
		push_error("[Teste] Arquivo Lua nao encontrado")
		return

	var result = lua.do_file(lua_file.resource_path)

	if result is LuaError:
		push_error("[Teste] Erro ao carregar mod Lua: %s" % result)
		return

	_lua = lua
	
	LuaUiEventBridge.register_into(_lua)
	LuaUiEventBridge.lua_event.connect(_on_lua_event)
	
	button.pressed.connect(_on_open_pressed.bind(button))
	label_state = {"name":label.text}


func _on_lua_event(event_name: String, data) -> void:
	match event_name:
		"state_changed":
			label_state = data
			label.text = label_state.get("name", "")
		"window_closed":
			_lua_handler_id = -1


func _on_open_pressed(btn: Control) -> void:
	if _lua_handler_id != -1:
		LuaUiBridge.close(_lua_handler_id)
		_lua_handler_id = -1
		return

	var raw_def = LuaHelpers.call_by_name(_lua, "onOpenWindow", [label_state])
	_lua_handler_id = LuaUiBridge.open_at(_lua, raw_def, btn)
	_lua.property_list_changed.connect(func(): print("property changed"))
	_lua.script_changed.connect(func(): print("script changed"))
	#print(_lua.get_signal_list().map(func(c): return c.name))
	label.text = label_state.name if label_state.has("name") else "" 


func _create_test_bounce() -> LuaUiAnimationPreset:
	var press_bounce := LuaUiAnimationPreset.new()
	press_bounce.property = "offset_transform_scale"
	press_bounce.from_value = Vector2(1, 1)
	press_bounce.to_value = Vector2(0.92, 0.92)
	press_bounce.duration = 0.08
	return press_bounce
	
func _create_test_pulse() -> LuaUiAnimationPreset:
	var soft_pulse := LuaUiAnimationPreset.new()
	soft_pulse.property = "offset_transform_scale"
	soft_pulse.from_value = Vector2(1, 1)
	soft_pulse.to_value = Vector2(1.02, 1.02)
	soft_pulse.loop = true
	soft_pulse.duration = 0.3
	return soft_pulse

func _create_test_theme() -> Theme:
	var theme := Theme.new()

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.4, 0.6, 1.0)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8

	theme.set_stylebox("panel", "PanelContainer", panel_style)
	theme.set_color("font_color", "Label", Color(0.9, 0.9, 1.0))

	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color(0.3, 0.4, 0.8)
	button_style.corner_radius_top_left = 4
	button_style.corner_radius_top_right = 4
	button_style.corner_radius_bottom_left = 4
	button_style.corner_radius_bottom_right = 4

	theme.set_stylebox("normal", "Button", button_style)
	
	var checkbox_style := StyleBoxFlat.new()
	checkbox_style.bg_color = Color(0.2, 0.2, 0.25) 
	theme.set_stylebox("normal", "CheckBox", checkbox_style)

	return theme
