class_name LuaUiFactory extends RefCounted

var _translation_resolver: Callable = Callable(self, "_default_translation_resolver")
var _component_builders: Dictionary = {}
var _manager: LuaUiManager = null
var _active_tweens: Dictionary = {}  # node (Object) -> Tween


func _init() -> void:
	register_component(LuaUiLabel.new())
	register_component(LuaUiButton.new())
	register_component(LuaUiScroll.new())
	register_component(LuaUiInput.new())
	register_component(LuaUiSlider.new())
	register_component(LuaUiCheckbox.new())
	register_component(LuaUiRadioGroup.new())
	register_component(LuaUiTextEdit.new())
	register_component(LuaUiTabbar.new())
	register_component(LuaUiColorPicker.new())
	register_component(LuaUiSprite.new())


func set_manager(manager: LuaUiManager) -> void:
	_manager = manager


# ---------------------------------------------------------------------------
# Component registry
# ---------------------------------------------------------------------------

func register_component(component: LuaUiComponent) -> void:
	var type_name := component.get_type_name()
	if type_name.is_empty():
		push_error("[LuaUiFactory] Componente sem type_name.")
		return
	
	_component_builders[type_name] = component


func set_translation_resolver(fn: Callable) -> void:
	_translation_resolver = fn


# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

func build_content(definition: Dictionary, index: Dictionary) -> Control:
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var context := LuaUiBuildContext.new(self, index, _translation_resolver, _manager)

	for raw_child in definition.get("children", []):
		content.add_child(build_node(raw_child, context))

	return wrap_with_padding(content, definition.get("padding"))


func build_node(definition: Dictionary, context: LuaUiBuildContext) -> Control:
	var type_name: String = definition.get("type", "")

	if type_name == "section":
		return _build_section(definition, context)

	if not _component_builders.has(type_name):
		push_error("[LuaUiFactory] Tipo de componente desconhecido: '%s'" % type_name)
		return Control.new()

	var component: LuaUiComponent = _component_builders[type_name]
	var node := component.build(definition, context)

	if node == null:
		push_error("[LuaUiFactory] Componente '%s' retornou null." % type_name)
		return Control.new()

	_apply_common_properties(node, definition, context)

	if definition.has("id"):
		context.component_index[definition["id"]] = node

	return node


# ---------------------------------------------------------------------------
# Section
# ---------------------------------------------------------------------------

func _build_section(definition: Dictionary, context: LuaUiBuildContext) -> Control:
	var direction: String = definition.get("direction", "vertical")

	var container: Container = (HBoxContainer.new() if direction == "horizontal" else VBoxContainer.new())

	if definition.has("align"):
		match str(definition["align"]):
			"start": container.alignment = BoxContainer.ALIGNMENT_BEGIN
			"center": container.alignment = BoxContainer.ALIGNMENT_CENTER
			"end": container.alignment = BoxContainer.ALIGNMENT_END

	if definition.has("gap"):
		container.add_theme_constant_override("separation", int(definition["gap"]))

	for raw_child in definition.get("children", []):
		container.add_child(build_node(raw_child, context))

	var result: Control = wrap_with_padding(container, definition.get("padding"))

	if definition.get("panel", false):
		var panel_wrap := PanelContainer.new()
		panel_wrap.add_child(result)
		result = panel_wrap

	if definition.has("style"):
		result.theme_type_variation = str(definition["style"])
	
	_apply_size_mode(result, definition)
	var size_mode: String = definition.get("size_mode", "")

	if definition.get("size_mode", "") == "fixed":
		result.clip_contents = true

	if definition.has("height"):
		result.custom_minimum_size.y = float(definition["height"])
	if definition.has("width"):
		result.custom_minimum_size.x = float(definition["width"])
	return result


# ---------------------------------------------------------------------------
# Padding
# ---------------------------------------------------------------------------

func parse_padding(value) -> Array:
	if value == null:
		return [0.0, 0.0, 0.0, 0.0]

	if value is int or value is float:
		var v := float(value)
		return [v, v, v, v]

	if value is Array:
		if value.size() == 2:
			var h := float(value[0])
			var v := float(value[1])
			return [h, v, h, v]

		if value.size() == 4:
			return [float(value[0]), float(value[1]), float(value[2]), float(value[3])]

	push_warning("[LuaUiFactory] padding inválido: %s" % str(value))
	return [0.0, 0.0, 0.0, 0.0]


func wrap_with_padding(node: Control, padding_value) -> Control:
	if padding_value == null:
		return node

	var p := parse_padding(padding_value)
	var margin := MarginContainer.new()

	margin.add_theme_constant_override("margin_left", int(p[0]))
	margin.add_theme_constant_override("margin_top", int(p[1]))
	margin.add_theme_constant_override("margin_right", int(p[2]))
	margin.add_theme_constant_override("margin_bottom", int(p[3]))

	margin.add_child(node)

	return margin


# ---------------------------------------------------------------------------
# Common properties
# ---------------------------------------------------------------------------

func _apply_common_properties(node: Control, definition: Dictionary, context: LuaUiBuildContext) -> void:
	if definition.has("theme"):
		var theme: Theme = context.get_theme(str(definition["theme"]))
		if theme != null:
			node.theme = theme
		else:
			push_warning("[LuaUiFactory] Tema não encontrado: %s" % definition["theme"])
	
	if definition.has("style"):
		node.theme_type_variation = str(definition["style"])
		print(str(definition["style"]))
	
	_apply_size_mode(node, definition)
	
	if (definition.has("width") or definition.has("height")):
		var size := node.custom_minimum_size
		if definition.has("width"):
			size.x = float(definition["width"])
		if definition.has("height"):
			size.y = float(definition["height"])
		node.custom_minimum_size = size

	if definition.has("visible"):
		node.visible = bool(definition["visible"])

	if definition.has("tooltip"):
		node.tooltip_text = context.resolve_text(definition["tooltip"])

	if (definition.has("disabled") and node.has_method("set_disabled")):
		node.set("disabled", bool(definition["disabled"]))

	if (definition.has("props") and definition["props"] is Dictionary):
		for key in definition["props"]:
			_set_generic_property(node, key, definition["props"][key])

	if definition.has("animation"):
		_apply_animation(node, definition["animation"], context)

	if definition.has("sound"):
		_apply_sound(node, definition["sound"], context)
	
	if definition.has("theme_overrides") and definition["theme_overrides"] is Dictionary:
		_apply_theme_overrides(node, definition["theme_overrides"])


func _apply_theme_overrides(node: Control, overrides: Dictionary) -> void:
	if overrides.has("colors"):
		for key in overrides["colors"]:
			node.add_theme_color_override(key, parse_color(overrides["colors"][key]))

	if overrides.has("constants"):
		for key in overrides["constants"]:
			node.add_theme_constant_override(key, int(overrides["constants"][key]))

	if overrides.has("font_sizes"):
		for key in overrides["font_sizes"]:
			node.add_theme_font_size_override(key, int(overrides["font_sizes"][key]))

	if overrides.has("fonts"):
		for key in overrides["fonts"]:
			var font := load(overrides["fonts"][key]) as Font
			if font != null:
				node.add_theme_font_override(key, font)
			else:
				push_warning("[LuaUiFactory] Fonte não encontrada: %s" % overrides["fonts"][key])

	if overrides.has("icons"):
		for key in overrides["icons"]:
			var texture := load(overrides["icons"][key]) as Texture2D
			if texture != null:
				node.add_theme_icon_override(key, texture)

	if overrides.has("styleboxes"):
		for key in overrides["styleboxes"]:
			var stylebox := load(overrides["styleboxes"][key]) as StyleBox
			if stylebox != null:
				node.add_theme_stylebox_override(key, stylebox)


func _set_generic_property(node: Object, key: String, raw_value) -> void:
	var current = node.get(key)

	if current == null and not (key in node):
		push_warning( "[LuaUiFactory] Propriedade '%s' não existe em %s"
			% [key, node.get_class()])
		return

	node.set(key, _coerce_value(current, raw_value))


func _coerce_value(current_value, new_value):
	if (current_value is Vector2 and new_value is Array and new_value.size() >= 2):
		return Vector2(float(new_value[0]), float(new_value[1]))

	if current_value is Color:
		return parse_color(new_value)

	if current_value is bool:
		return bool(new_value)

	if current_value is int:
		return int(new_value)

	if current_value is float:
		return float(new_value)

	return new_value


func _apply_animation(node: Control, animation_def: Dictionary, context: LuaUiBuildContext) -> void:
	node.offset_transform_enabled = true
	node.offset_transform_visual_only = true
	

	if animation_def.has("hover"):
		var preset := context.get_animation(animation_def["hover"])
		if preset != null:
			node.mouse_entered.connect(func(): _start_hover_animation(node, preset))
			node.mouse_exited.connect(func(): _stop_hover_animation(node, preset))

	if animation_def.has("click"):
		var preset := context.get_animation(animation_def["click"])
		if preset != null:
			node.mouse_filter = Control.MOUSE_FILTER_STOP
			node.gui_input.connect(func(event):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					_play_animation(node, preset, true)
					if preset.auto_revert:
						await node.get_tree().create_timer(preset.duration).timeout
						if is_instance_valid(node):
							_play_animation(node, preset, false)
			)


func _start_hover_animation(node: Control, preset: LuaUiAnimationPreset) -> void:
	_stop_hover_animation(node, preset)  # evita empilhar tweens duplicados

	var tween := node.create_tween()
	_active_tweens[node] = tween

	if preset.loop:
		tween.set_loops()  # sem argumento = infinito
		tween.tween_property(node, preset.property, preset.to_value, preset.duration)\
			.set_trans(preset.trans_type).set_ease(preset.ease_type)
		tween.tween_property(node, preset.property, preset.from_value, preset.duration)\
			.set_trans(preset.trans_type).set_ease(preset.ease_type)
	else:
		tween.tween_property(node, preset.property, preset.to_value, preset.duration)\
			.set_trans(preset.trans_type).set_ease(preset.ease_type)


func _stop_hover_animation(node: Control, preset: LuaUiAnimationPreset) -> void:
	if _active_tweens.has(node):
		var old_tween: Tween = _active_tweens[node]
		if is_instance_valid(old_tween):
			old_tween.kill()
		_active_tweens.erase(node)

	var tween := node.create_tween()
	tween.tween_property(node, preset.property, preset.from_value, preset.duration)\
		.set_trans(preset.trans_type).set_ease(preset.ease_type)


func _play_animation(node: Control, preset: LuaUiAnimationPreset, entering: bool) -> void:
	var target = preset.to_value if entering else preset.from_value
	var tween := node.create_tween()
	tween.tween_property(node, preset.property, target, preset.duration)\
		.set_trans(preset.trans_type).set_ease(preset.ease_type)


func _apply_sound(node: Control, sound_def: Dictionary, context: LuaUiBuildContext) -> void:
	if sound_def.has("hover"):
		var stream := context.get_sound(sound_def["hover"])
		if stream != null:
			node.mouse_entered.connect(func(): _play_sound(stream))

	if sound_def.has("click"):
		var stream := context.get_sound(sound_def["click"])
		if stream != null:
			node.mouse_filter = Control.MOUSE_FILTER_STOP
			node.gui_input.connect(func(event):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					_play_sound(stream)
			)


func _play_sound(stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	Engine.get_main_loop().root.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


# ---------------------------------------------------------------------------
# Utils
# ---------------------------------------------------------------------------

static func _apply_size_mode(node: Control, definition: Dictionary) -> void:
	match definition.get("size_mode", ""):
		"fill":
			node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			node.size_flags_vertical = Control.SIZE_EXPAND_FILL
			if definition.has("ratio"):
				node.size_flags_stretch_ratio = float(definition["ratio"])
		"fixed":
			node.size_flags_horizontal = Control.SIZE_FILL
			node.size_flags_vertical = Control.SIZE_FILL
		"fit":
			node.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			node.size_flags_vertical = Control.SIZE_SHRINK_BEGIN


static func parse_color(value) -> Color:
	if value is Color:
		return value

	if value is String:
		return Color(value)

	if value is Array and value.size() >= 3:
		var alpha := 1.0

		if value.size() > 3:
			alpha = float(value[3])
		return Color(float(value[0]), float(value[1]), float(value[2]), alpha)

	return Color.WHITE


func _default_translation_resolver(key: String) -> String:
	return key
