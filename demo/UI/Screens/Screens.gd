extends Control
## Projeto consumidor de teste: carrega os .lua e o .lcss da pasta, mantém as settings
## reativas e troca de tela destruindo os componentes antigos e criando os novos.

const LUA_DIR := "res://demo/UI/Screens/lua/"
const LUA_FILES := ["confirm_dialog.lua", "main_menu.lua", "settings.lua"]
const LCSS_FILE := "res://demo/UI/Screens/screens.lcss"

## Cena aberta pelo PLAY.
@export_file("*.tscn") var play_scene: String = ""

var settings := ReactiveDictionary.new({
	"resolution": "1920x1080",
	"vsync": 1,
	"volume": 80,
})

var _screen: LuaComponent


func _ready() -> void:
	LuaUi.set_root(self)
	LuaUi.expose_store("settings", settings)
	LuaUi.load_lcss(LCSS_FILE)
	for file in LUA_FILES:
		LuaUi.load_file(LUA_DIR + file)
	# o motor reage à store: APPLY e SAVE só precisam escrever nela
	settings.reactive_changed.connect(_on_settings_changed)
	show_screen("MainMenu")


func show_screen(component: String) -> void:
	if is_instance_valid(_screen):
		_screen.dispose()
		_screen = null
	LuaUi.release_drafts()
	var el := ComponentRegistry.make_element(component, {"on_navigate": Callable(self, "_on_navigate")})
	_screen = ComponentRegistry.instantiate(el) as LuaComponent
	add_child(_screen)


func _on_navigate(target: Variant) -> void:
	match str(target):
		"main_menu": show_screen("MainMenu")
		"settings": show_screen("SettingsScreen")
		"play": _play()
		"quit": get_tree().quit()
		_: push_warning("[Screens] destino desconhecido: '%s'" % target)


func _play() -> void:
	if play_scene == "":
		push_warning("[Screens] defina play_scene no Inspector.")
		return
	get_tree().change_scene_to_file(play_scene)


func _on_settings_changed(_reactive: Reactive) -> void:
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if int(settings.get_at("vsync")) != 0 else DisplayServer.VSYNC_DISABLED)
	AudioServer.set_bus_volume_db(0, linear_to_db(clampf(float(settings.get_at("volume")) / 100.0, 0.0, 1.0)))
	var parts := str(settings.get_at("resolution")).split("x")
	if parts.size() == 2 and parts[0].is_valid_int() and parts[1].is_valid_int():
		DisplayServer.window_set_size(Vector2i(parts[0].to_int(), parts[1].to_int()))
