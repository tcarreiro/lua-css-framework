extends Node2D

const CLICK_1 = preload("uid://58qresn5blvp")
const SWITCH_2 = preload("uid://c18lo7uas6cea")

@export var lua_file: Resource

@onready var label: Label = %Label
@onready var button: Button = %Button

var ui_bridge: UiBridge

var _lua_handler_id := -1
var label_state = {}

func _ready() -> void:
	_setup_ui_bridge()
	
	_read_lua_file()
	_connect_buttons()


func _setup_ui_bridge() -> void:
	ui_bridge = UiBridge.new()
	ui_bridge.lua_event.connect(_on_lua_event)
	
	ui_bridge.register_animation("soft_pulse", _create_test_pulse())
	ui_bridge.register_animation("press_bounce", _create_test_bounce())

	ui_bridge.register_sound("ui_hover", CLICK_1)
	ui_bridge.register_sound("ui_click", SWITCH_2)


func _read_lua_file() -> void:
	if not lua_file:
		push_error("[Teste] Arquivo Lua nao encontrado")
		return

	var state_name := ui_bridge.get_state_name()
	var state: LuaState = LuaBridgeRegistry.get_lua_state(state_name)
	var result = state.do_file(lua_file.resource_path)

	if result is LuaError:
		push_error("[Teste] Erro ao carregar mod Lua: %s" % result)
		return


func _connect_buttons() -> void:
	button.pressed.connect(_on_open_pressed.bind(button))
	label_state = {"name":label.text}


func _on_lua_event(event_name: String, data) -> void:
	match event_name:
		"state_changed":
			label_state = data
			label.text = label_state.get("name", "")
		"window_closed":
			print(event_name)
			_lua_handler_id = -1


func _on_open_pressed(btn: Control) -> void:
	if _lua_handler_id != -1:
		ui_bridge.close(_lua_handler_id)
		_lua_handler_id = -1
		return

	var ui_state_name := ui_bridge.get_state_name()
	var ui_state: LuaState = LuaBridgeRegistry.get_lua_state(ui_state_name)
	var raw_def = LuaHelper.call_by_name(ui_state, "onOpenWindow", [label_state])
	_lua_handler_id = ui_bridge.open_at(ui_state, raw_def, btn)
	#_lua_handler_id = ui_bridge.open_ui(ui_state, raw_def)
	
	ui_state.property_list_changed.connect(func(): print("property changed"))
	ui_state.script_changed.connect(func(): print("script changed"))
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
