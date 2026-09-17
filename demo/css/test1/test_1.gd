extends Control

@export var lua_file: Resource

@onready var label: Label = %Label
@onready var button: Button = %Button

var _lua: LuaState
var _lua_handler_id := -1
var label_state = {}

const CLICK_1 = preload("uid://58qresn5blvp")
const SWITCH_2 = preload("uid://c18lo7uas6cea")

func _ready() -> void:
	#GDSSUiBridge._set_gdss_classes_on_node(button, ["accent"]) # -> change Control Style Class
	#GdssNodeHandler.refresh(button)
	
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
	
	LuaContentBridge.register_into(_lua)
	
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
	#_lua_handler_id = LuaUiBridge.open_ui(_lua, raw_def)
	
	_lua.property_list_changed.connect(func(): print("property changed"))
	_lua.script_changed.connect(func(): print("script changed"))
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
