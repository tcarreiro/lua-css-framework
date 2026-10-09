class_name LCSSAppliers extends RefCounted
## Handler único usado por TODO componente que registra propriedades em um
## LCSSStyleTarget. Sabe COMO cada propriedade vira Godot de verdade; o componente
## só declara ONDE. Recebe sempre nomes CANÔNICOS (ComponentProps.*), nunca o contexto
## escrito no .lua/.lcss (quem traduz contexto -> canônico é o LCSSStyleTarget).

#region Meta names
const LCSS_APPLIED_PREFIX := &"_lcss_applied_"
const LCSS_BOX := &"_lcss_box"
const LCSS_SCROLLBAR := &"_lcss_scrollbar"
#endregion

# mesma ordem de ComponentProps.FAMILIES
const _SIDES := [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]
const _CORNERS := [CORNER_TOP_LEFT, CORNER_TOP_RIGHT, CORNER_BOTTOM_RIGHT, CORNER_BOTTOM_LEFT]
# padding também usa margin_*: o alvo é um MarginContainer
const _MARGIN_CONSTANTS := ["margin_left", "margin_top", "margin_right", "margin_bottom"]


static func apply(property: StringName, value: Variant, target: Node) -> void:
	match property:
		ComponentProps.BACKGROUND_COLOR, ComponentProps.BORDER_COLOR, \
		ComponentProps.DROP_SHADOW_COLOR, ComponentProps.DROP_SHADOW_SIZE, \
		ComponentProps.DROP_SHADOW_OFFSET:
			_apply_stylebox_field(target as Control, property, value)
		ComponentProps.FONT_COLOR, ComponentProps.FONT_SIZE, \
		ComponentProps.OUTLINE_COLOR, ComponentProps.OUTLINE_THICKNESS:
			_apply_text_style(target as Control, property, value)
		ComponentProps.SCROLLBAR_WIDTH, ComponentProps.SCROLLBAR_TRACK_COLOR, \
		ComponentProps.SCROLLBAR_GRABBER_COLOR, ComponentProps.SCROLLBAR_GRABBER_HOVER_COLOR, \
		ComponentProps.SCROLLBAR_GRABBER_PRESSED_COLOR, ComponentProps.SCROLL_HINT_COLOR:
			_apply_scrollbar(target as ScrollContainer, property, value)
		ComponentProps.SCROLLBAR_GAP:
			_apply_scrollbar_gap(target as ScrollContainer, value)
		# TODO: SCROLL_HINT e SCROLL_HINT_TILE entram aqui quando existir o handler de textura
		_:
			push_warning("[LCSSAppliers] propriedade sem applier: '%s'" % property)


#region Famílias
## Recebe UM valor por parte (ordem de ComponentProps.FAMILIES); null = indefinido.
static func apply_family(family: StringName, values: Array, target: Node) -> void:
	match family:
		ComponentProps.MARGIN, ComponentProps.PADDING:
			_apply_box_family(target as MarginContainer, family, values)
		ComponentProps.BORDER_WIDTH, ComponentProps.BORDER_RADIUS:
			_apply_border_family(target as Control, family, values)
		ComponentProps.SCROLLBAR_BORDER_RADIUS:
			_apply_scrollbar_radius(target as ScrollContainer, values)
		_:
			push_warning("[LCSSAppliers] família sem applier: '%s'" % family)


static func _apply_box_family(node: MarginContainer, family: StringName, values: Array) -> void:
	if node == null:
		return
	node.begin_bulk_theme_override()
	_apply_parts(node, family, values,
		func(i, v): node.add_theme_constant_override(_MARGIN_CONSTANTS[i], int(v)),
		func(i): node.remove_theme_constant_override(_MARGIN_CONSTANTS[i]))
	node.end_bulk_theme_override()


static func _apply_border_family(target: Control, family: StringName, values: Array) -> void:
	if target == null:
		return
	# não cria StyleBoxFlat à toa: só com valor, ou se já existe (para poder desfazer)
	if not _has_any(values) and not target.has_meta(LCSS_BOX):
		return
	var box := _get_box(target)
	if family == ComponentProps.BORDER_WIDTH:
		_apply_parts(target, family, values,
			func(i, v): box.set_border_width(_SIDES[i], int(v)),
			func(i): box.set_border_width(_SIDES[i], 0))
	else:
		_apply_parts(target, family, values,
			func(i, v): box.set_corner_radius(_CORNERS[i], int(v)),
			func(i): box.set_corner_radius(_CORNERS[i], 0))


## Aplica as partes não nulas e desfaz as que ESTE applier aplicou antes e que agora
## estão indefinidas (ex.: um padding_left que existia só no :hover).
## O que o .tscn definiu à mão nunca é tocado. Os callables recebem o ÍNDICE da parte.
static func _apply_parts(target: Object, family: StringName, values: Array,
		set_fn: Callable, reset_fn: Callable) -> void:
	var meta_key := StringName("%s%s" % [LCSS_APPLIED_PREFIX, family])
	var applied: Dictionary = target.get_meta(meta_key, {})
	for i in values.size():
		if values[i] != null:
			set_fn.call(i, values[i])
			applied[i] = true
		elif applied.has(i):
			reset_fn.call(i)
			applied.erase(i)
	target.set_meta(meta_key, applied)


static func _has_any(values: Array) -> bool:
	for v in values:
		if v != null:
			return true
	return false
#endregion


#region Painel / texto
## Um StyleBoxFlat próprio por Panel/PanelContainer/ScrollContainer (todos usam o slot
## "panel"), guardado como meta NO PRÓPRIO node — morre junto com ele.
static func _get_box(target: Control) -> StyleBoxFlat:
	if target.has_meta(LCSS_BOX):
		return target.get_meta(LCSS_BOX)
	var box := StyleBoxFlat.new()
	box.bg_color = Color.TRANSPARENT   # o default do engine é cinza opaco
	target.set_meta(LCSS_BOX, box)
	target.add_theme_stylebox_override("panel", box)
	return box


static func _apply_stylebox_field(target: Control, property: StringName, value: Variant) -> void:
	if target == null or value == null:
		return
	var box := _get_box(target)
	match property:
		ComponentProps.BACKGROUND_COLOR: box.bg_color = LuaHelper.parse_color(value)
		ComponentProps.BORDER_COLOR: box.border_color = LuaHelper.parse_color(value)
		ComponentProps.DROP_SHADOW_COLOR: box.shadow_color = LuaHelper.parse_color(value)
		ComponentProps.DROP_SHADOW_SIZE: box.shadow_size = int(value)
		ComponentProps.DROP_SHADOW_OFFSET:
			var v := LuaHelper.parse_distributable(value)
			box.shadow_offset = Vector2(v[0], v[1])


## Quem decide QUAL alvo recebe é o contexto no LCSSStyleTarget; aqui o nome é canônico.
static func _apply_text_style(target: Control, property: StringName, value: Variant) -> void:
	if target == null or value == null:
		return
	match property:
		ComponentProps.FONT_COLOR:
			var color := LuaHelper.parse_color(value)
			target.add_theme_color_override("font_color", color)
			if target is LineEdit:
				target.add_theme_color_override("font_uneditable_color", color)
		ComponentProps.FONT_SIZE:
			target.add_theme_font_size_override("font_size", int(value))
		ComponentProps.OUTLINE_COLOR:
			target.add_theme_color_override("font_outline_color", LuaHelper.parse_color(value))
		ComponentProps.OUTLINE_THICKNESS:
			target.add_theme_constant_override("outline_size", int(value))
#endregion


#region Scrollbar
static func _apply_scrollbar(scroll: ScrollContainer, property: StringName, value: Variant) -> void:
	if scroll == null or value == null:
		return
	var cfg: Dictionary = scroll.get_meta(LCSS_SCROLLBAR, {})
	cfg[property] = value
	scroll.set_meta(LCSS_SCROLLBAR, cfg)
	_rebuild_scrollbar(scroll)


## Os 4 cantos vêm da família (um valor por canto, null = 0).
static func _apply_scrollbar_radius(scroll: ScrollContainer, values: Array) -> void:
	if scroll == null:
		return
	var cfg: Dictionary = scroll.get_meta(LCSS_SCROLLBAR, {})
	if not _has_any(values) and not cfg.has(ComponentProps.SCROLLBAR_BORDER_RADIUS):
		return
	cfg[ComponentProps.SCROLLBAR_BORDER_RADIUS] = values
	scroll.set_meta(LCSS_SCROLLBAR, cfg)
	_rebuild_scrollbar(scroll)


static func _rebuild_scrollbar(scroll: ScrollContainer) -> void:
	var cfg: Dictionary = scroll.get_meta(LCSS_SCROLLBAR, {})
	var thickness := maxi(int(cfg.get(ComponentProps.SCROLLBAR_WIDTH, 12)), 1)
	var track_color := LuaHelper.parse_color(cfg.get(ComponentProps.SCROLLBAR_TRACK_COLOR, Color(0, 0, 0, 0.1)))
	var grabber_color := LuaHelper.parse_color(cfg.get(ComponentProps.SCROLLBAR_GRABBER_COLOR, Color(1, 1, 1, 0.3)))
	var hover_color := LuaHelper.parse_color(cfg.get(ComponentProps.SCROLLBAR_GRABBER_HOVER_COLOR, grabber_color))
	var pressed_color := LuaHelper.parse_color(cfg.get(ComponentProps.SCROLLBAR_GRABBER_PRESSED_COLOR, grabber_color))
	var radius: Array = cfg.get(ComponentProps.SCROLLBAR_BORDER_RADIUS, [])

	if cfg.has(ComponentProps.SCROLL_HINT_COLOR):
		var hint := LuaHelper.parse_color(cfg[ComponentProps.SCROLL_HINT_COLOR])
		scroll.add_theme_color_override("scroll_hint_vertical_color", hint)
		scroll.add_theme_color_override("scroll_hint_horizontal_color", hint)

	_style_bar(scroll.get_v_scroll_bar(), true, thickness, track_color, grabber_color, hover_color, pressed_color, radius)
	_style_bar(scroll.get_h_scroll_bar(), false, thickness, track_color, grabber_color, hover_color, pressed_color, radius)


static func _style_bar(bar: ScrollBar, vertical: bool, thickness: int, track_color: Color,
		grabber_color: Color, hover_color: Color, pressed_color: Color, radius: Array) -> void:
	var track := StyleBoxFlat.new()
	track.bg_color = track_color
	_set_corners(track, radius)

	# Espessura no eixo CRUZADO. Segundo as docs de H/VScrollBar, as content margins de
	# `scroll` NO EIXO da barra viram padding do grabber, então ficam em 0.
	var half := thickness / 2.0
	if vertical:
		track.content_margin_left = half
		track.content_margin_right = half
		track.content_margin_top = 0
		track.content_margin_bottom = 0
	else:
		track.content_margin_top = half
		track.content_margin_bottom = half
		track.content_margin_left = 0
		track.content_margin_right = 0

	bar.begin_bulk_theme_override()
	bar.add_theme_stylebox_override("scroll", track)
	bar.add_theme_stylebox_override("scroll_focus", track)
	bar.add_theme_stylebox_override("grabber", _grabber_box(grabber_color, radius))
	bar.add_theme_stylebox_override("grabber_highlight", _grabber_box(hover_color, radius))
	bar.add_theme_stylebox_override("grabber_pressed", _grabber_box(pressed_color, radius))
	bar.end_bulk_theme_override()


static func _grabber_box(color: Color, radius: Array) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	_set_corners(box, radius)
	return box


static func _set_corners(box: StyleBoxFlat, r: Array) -> void:
	for i in 4:
		box.set_corner_radius(_CORNERS[i], _corner(r, i))


static func _corner(r: Array, i: int) -> int:
	return maxi(int(r[i]), 0) if r.size() > i and r[i] != null else 0


## Doc: scrollbar_h_separation = espaço entre a barra VERTICAL e o conteúdo;
## scrollbar_v_separation = espaço entre a barra HORIZONTAL e o conteúdo.
static func _apply_scrollbar_gap(scroll: ScrollContainer, value: Variant) -> void:
	if scroll == null or value == null:
		return
	var g := LuaHelper.parse_distributable(value)
	scroll.add_theme_constant_override("scrollbar_h_separation", int(g[0]))
	scroll.add_theme_constant_override("scrollbar_v_separation", int(g[1]))
#endregion
