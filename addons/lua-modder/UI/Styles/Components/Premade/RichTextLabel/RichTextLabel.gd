extends LuaComponent

@onready var _rt: Variant = self


func get_schema() -> Dictionary:
	var names: Array = [ComponentProps.TEXT, ComponentProps.WIDTH, ComponentProps.HEIGHT,
			ComponentProps.MAX_WIDTH, ComponentProps.MAX_HEIGHT]
	names.append_array(ComponentProps.TEXT_LAYOUT)
	names.append_array(ComponentProps.RICH_ONLY)
	names.append_array(ComponentProps.FONT)
	names.append_array(ComponentProps.TEXT_SHADOW)
	return {
		"name": "RichTextLabel",
		"props": ComponentProps.pick(names, {ComponentProps.AUTOWRAP: "word_smart"}),
		"events": ["meta_clicked", "meta_hover_started", "meta_hover_ended"],
		"methods": ["append_text", "scroll_to_line", "scroll_to_end", "clear_text"],
	}


func _ready() -> void:
	_style_target.register_group(ComponentProps.FONT, self)
	_style_target.register_group(ComponentProps.TEXT_SHADOW, self)
	for prop in [ComponentProps.LINE_SPACING, ComponentProps.PARAGRAPH_SPACING,
			ComponentProps.SELECTION_COLOR, ComponentProps.SELECTED_FONT_COLOR]:
		_style_target.register_property(prop, self)
	super._ready()


func _component_ready() -> void:
	_rt.meta_clicked.connect(func(meta): emit_event("meta_clicked", [str(meta)]))
	_rt.meta_hover_started.connect(func(meta): emit_event("meta_hover_started", [str(meta)]))
	_rt.meta_hover_ended.connect(func(meta): emit_event("meta_hover_ended", [str(meta)]))


func _apply_prop(key: String, value: Variant) -> void:
	if not value:
		return
	match StringName(key):
		ComponentProps.TEXT, ComponentProps.BBCODE_ENABLED:
			_refresh_text()
		ComponentProps.TEXT_ALIGN:
			_rt.horizontal_alignment = ComponentProps.H_ALIGNS.get(StringName(str(value)), HORIZONTAL_ALIGNMENT_LEFT)
		ComponentProps.TEXT_VALIGN:
			_rt.vertical_alignment = ComponentProps.V_ALIGNS.get(StringName(str(value)), VERTICAL_ALIGNMENT_TOP)
		ComponentProps.AUTOWRAP:
			_rt.autowrap_mode = ComponentProps.AUTOWRAP_MODES.get(StringName(str(value)), TextServer.AUTOWRAP_WORD_SMART)
		ComponentProps.FIT_CONTENT:
			_rt.fit_content = bool(value)
		ComponentProps.SCROLL_ACTIVE:
			_rt.scroll_active = bool(value)
		ComponentProps.SCROLL_FOLLOWING:
			_rt.scroll_following = bool(value)
		ComponentProps.SCROLL_FOLLOWING_VISIBLE:
			_rt.scroll_following_visible_characters = bool(value)
		ComponentProps.SELECTION_ENABLED:
			_rt.selection_enabled = bool(value)
		ComponentProps.META_UNDERLINED:
			_rt.meta_underlined = bool(value)
		ComponentProps.HINT_UNDERLINED:
			_rt.hint_underlined = bool(value)
		ComponentProps.TAB_SIZE:
			_rt.tab_size = int(value)
		ComponentProps.VISIBLE_CHARACTERS:
			_rt.visible_characters = int(value)
		ComponentProps.VISIBLE_RATIO:
			_rt.visible_ratio = float(value)
		ComponentProps.AUTO_FONT_SIZE:
			_rt.resize_font_to_fit = bool(value)
		ComponentProps.MIN_FONT_SIZE:
			_rt.minimum_font_size = int(value)
		ComponentProps.MAX_FONT_SIZE:
			_rt.maximum_font_size = int(value)
		ComponentProps.WIDTH:
			if int(value) >= 0: custom_minimum_size.x = value
		ComponentProps.HEIGHT:
			if int(value) >= 0: custom_minimum_size.y = value
		ComponentProps.MAX_WIDTH:
			custom_maximum_size.x = float(value)   # < 0 = sem limite
		ComponentProps.MAX_HEIGHT:
			custom_maximum_size.y = float(value)
		_:
			super._apply_prop(key, value)


## Lê de `props`, que já vem resolvido: a ordem em que as props chegam não importa.
## O bbcode é ligado antes do texto, para o texto ser interpretado.
func _refresh_text() -> void:
	_rt.bbcode_enabled = bool(props.get("bbcode_enabled", true))
	_rt.text = str(props.get("text", ""))


#region Métodos expostos ao Lua
## Acrescenta texto sem reconstruir tudo (a doc recomenda isso a `text +=`). Bom para log e chat.
func append_text(bbcode: String) -> void:
	_rt.append_text(bbcode)


func clear_text() -> void:
	_rt.clear()


func scroll_to_line(line: int) -> void:
	_rt.scroll_to_line(line)


func scroll_to_end() -> void:
	await get_tree().process_frame
	_rt.scroll_to_line(maxi(_rt.get_line_count() - 1, 0))
#endregion
