extends Control
## Projeto consumidor de teste: carrega os .lua e o .lcss da pasta, mantém as settings
## reativas e troca de tela destruindo os componentes antigos e criando os novos.

const LUA_DIR := "res://demo/UI/Screens/lua/"
const LUA_FILES := ["confirm_dialog.lua", "main_menu.lua", "settings.lua"]
const LCSS_FILE := ["res://demo/UI/Screens/screens.lcss", "res://addons/lua-modder/UI/Styles/layout.lcss"]

## Cena aberta pelo PLAY.
@export_file("*.tscn") var play_scene: String = ""

func _ready() -> void:
	var parser := LCSSParser.new()
	var text = """
	.menu-button {
		background_color: #2b3040;
		border_color: #4a5270;
		border_width: 2;
		border_radius: 6;
		padding: 14;
		font_color: #e8ecff;
		font_size: 22;
		transition_duration: 150ms;
		transition_duration: 150ms;
		transition_easing: ease_out;
		scale: 1.0;
		rotate: 0;
		translate: 0 0;
	}
	
	.menu-button:hover {
		background_color: #3a4260;
		scale: 1.08;
		rotate: -2;
		animation_name: hang;
		animation_duration: 1.2s;
		animation_easing: ease_in_out;
		animation_iterations: infinite;
	}

	.menu-button:pressed {
		background_color: #1f2433;
		scale: 0.97;
		translate: 0 -2;
	}
	@keyframes pulse {
		0%   { scale: 1;    background_color: #202020; }
		50%  { scale: 1.08; background_color: #303050; }
		100% { scale: 1;    background_color: #202020; }
	}
	// Comment 2
	"""
	
	var style_sheet := parser.parse(text)
	#print(style_sheet.keyframes)
	#print(style_sheet.style_classes)
	#print(style_sheet.comments)

#var settings := ReactiveDictionary.new({
	#"resolution_options": [
		#"1280x720", "1920x1080", "2560x1440"
	#],
	#"resolution": "1920x1080",
	#"vsync": true,
	#"volume": 80,
	#"quality_options": [
		#{ value = 1, label = "Baixa" }, { value = 2, label = "Média" }, { value = 3, label = "Alta" }
	#],
	#"quality": 1,
#})
#
#var _screen: LuaComponent
#
#
#func _ready() -> void:
	#LuaUi.set_root(self)
	#LuaUi.expose_store("settings", settings)
	#for file in LCSS_FILE:
		#LuaUi.load_lcss(file)
	#for file in LUA_FILES:
		#LuaUi.load_file(LUA_DIR + file)
	## o motor reage à store: APPLY e SAVE só precisam escrever nela
	#settings.reactive_changed.connect(_on_settings_changed)
	#show_screen("MainMenu")
#
#
#func show_screen(component: String) -> void:
	#if is_instance_valid(_screen):
		#_screen.dispose()
		#_screen = null
	#LuaUi.release_drafts()
	#var el := ComponentRegistry.make_element(component, {"on_navigate": Callable(self, "_on_navigate")})
	#_screen = ComponentRegistry.instantiate(el) as LuaComponent
	#add_child(_screen)
#
#
#func _on_navigate(target: Variant) -> void:
	#match str(target):
		#"main_menu": show_screen("MainMenu")
		#"settings": show_screen("SettingsScreen")
		#"play": _play()
		#"quit": get_tree().quit()
		#_: push_warning("[Screens] destino desconhecido: '%s'" % target)
#
#
#func _play() -> void:
	#if play_scene == "":
		#push_warning("[Screens] defina play_scene no Inspector.")
		#return
	#get_tree().change_scene_to_file(play_scene)
#
#
#func _on_settings_changed(_reactive: Reactive) -> void:
	#DisplayServer.window_set_vsync_mode(
		#DisplayServer.VSYNC_ENABLED if settings.get_at("vsync", false) else DisplayServer.VSYNC_DISABLED)
	#AudioServer.set_bus_volume_db(0, linear_to_db(clampf(float(settings.get_at("volume")) / 100.0, 0.0, 1.0)))
	#var parts := str(settings.get_at("resolution")).split("x")
	#if parts.size() == 2 and parts[0].is_valid_int() and parts[1].is_valid_int():
		#var resolution := str(settings.get_at("resolution")).split("x")
		#if resolution.size() == 2:
			#var target_size := Vector2i(
				#resolution[0].to_int(),
				#resolution[1].to_int()
			#)
#
			#get_tree().root.content_scale_size = target_size
#
			#if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED: # TODO: low res is hiding 
				#DisplayServer.window_set_size(target_size)
#
			#await get_tree().process_frame
