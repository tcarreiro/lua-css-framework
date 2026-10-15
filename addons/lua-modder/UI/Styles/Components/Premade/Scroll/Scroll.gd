extends LuaComponent

@onready var _margin: MarginContainer = %Margin
@onready var _items: LuaFlowBox = %Items
@onready var _sc: Variant = self

var _at_start := true
var _at_end := false

func get_schema() -> Dictionary:
	var names: Array = [
		LCSS.PADDING, LCSS.GAP,
		LCSS.WIDTH, LCSS.HEIGHT,
		LCSS.MAX_WIDTH, LCSS.MAX_HEIGHT,
		LCSS.DIRECTION, LCSS.SCROLLBAR_MODE,
		LCSS.FOLLOW_FOCUS, LCSS.EDGE_THRESHOLD,
		LCSS.SCROLL_HINT, LCSS.SCROLL_HINT_TILE,
		LCSS.DISPLAY
	]
	names.append_array(LCSS.PANEL)
	names.append_array(LCSS.SCROLLBAR)   # inclui scrollbar_gap e o raio por canto
	return {
		"name": "Scroll",
		"props": LCSS.pick(names, {LCSS.GAP: 4}),
		"events": ["scrolled", "reached_start", "reached_end", "scroll_started", "scroll_ended"],
		"methods": ["scroll_to_top", "scroll_to_bottom", "scroll_to_ref"],
		"slots": {"default": "%Items"},
	}


func _ready() -> void:
	_style_target.register_property(LCSS.PADDING, _margin)
	for prop in LCSS.SCROLLBAR:
		_style_target.register_property(prop, _sc)
	for prop in LCSS.PANEL:
		_style_target.register_property(prop, _sc)
	super._ready()


func _component_ready() -> void:
	_sc.scroll_started.connect(func(): emit_event("scroll_started"))
	_sc.scroll_ended.connect(func(): emit_event("scroll_ended"))

	var v_bar: ScrollBar = _sc.get_v_scroll_bar()
	var h_bar: ScrollBar = _sc.get_h_scroll_bar()
	v_bar.value_changed.connect(func(_v): _on_scrolled())
	h_bar.value_changed.connect(func(_v): _on_scrolled())
	# max_value/page mudam quando o conteúdo cresce, sem o value mudar
	v_bar.changed.connect(_check_edges)
	h_bar.changed.connect(_check_edges)


func _apply_prop(key: String, value: Variant) -> void:
	match key:
		LCSS.DIRECTION, LCSS.SCROLLBAR_MODE:
			_refresh_scroll_modes()
		LCSS.WIDTH:
			if value != null and int(value) >= 0:
				custom_minimum_size.x = value
		LCSS.HEIGHT:
			if value != null and int(value) >= 0:
				custom_minimum_size.y = value
		LCSS.MAX_WIDTH:
			if value != null:
				custom_maximum_size.x = float(value)   # < 0 = sem limite (doc)
		LCSS.MAX_HEIGHT:
			if value != null:
				custom_maximum_size.y = float(value)
		LCSS.GAP:
			_items.add_theme_constant_override("separation", int(value))
		LCSS.FOLLOW_FOCUS:
			_sc.follow_focus = value
		LCSS.SCROLL_HINT:
			_sc.scroll_hint_mode = LCSS.HINT_MODES.get(StringName(value), ScrollContainer.SCROLL_HINT_MODE_DISABLED)
		LCSS.SCROLL_HINT_TILE:
			_sc.tile_scroll_hint = value
		LCSS.DISPLAY:
			_items.vertical = (value != LCSS.FLEX)
			_items.refresh_flow()
		_:
			super._apply_prop(key, value)


func _refresh_scroll_modes() -> void:
	var dir := StringName(props.get(LCSS.DIRECTION, LCSS.BOTH))
	var base: int = LCSS.SCROLL_MODES.get(
			StringName(props.get(LCSS.SCROLLBAR_MODE, LCSS.AUTO)), ScrollContainer.SCROLL_MODE_AUTO)
	var h_max := int(props.get(LCSS.MAX_WIDTH, -1)) >= 0
	var v_max := int(props.get(LCSS.MAX_HEIGHT, -1)) >= 0
	_sc.horizontal_scroll_mode = _axis_mode(dir != LCSS.VERTICAL, h_max, base)
	_sc.vertical_scroll_mode = _axis_mode(dir != LCSS.HORIZONTAL, v_max, base)
	_sc.scroll_horizontal_by_default = (dir == LCSS.HORIZONTAL)


func _axis_mode(enabled: bool, has_max: bool, base: int) -> int:
	if not enabled:
		return ScrollContainer.SCROLL_MODE_DISABLED
	if base == ScrollContainer.SCROLL_MODE_AUTO and has_max:
		return ScrollContainer.SCROLL_MODE_MAXIMIZE_FIRST
	return base


#region Métodos expostos ao Lua (UI.callMethod)
func scroll_to_top() -> void:
	_sc.scroll_vertical = 0


func scroll_to_bottom() -> void:
	await get_tree().process_frame   # o layout precisa assentar (doc de scroll_vertical)
	var bar: ScrollBar = _sc.get_v_scroll_bar()
	_sc.scroll_vertical = int(bar.max_value - bar.page)


func scroll_to_ref(ref: String) -> void:
	var target := ComponentRegistry.get_ref(ref)
	if target:
		await get_tree().process_frame   # não funciona no mesmo frame em que o nó foi adicionado (doc)
		_sc.ensure_control_visible(target)
#endregion


#region Eventos
func _on_scrolled() -> void:
	emit_event("scrolled", [_sc.scroll_horizontal, _sc.scroll_vertical])
	_check_edges()


func _check_edges() -> void:
	var horizontal: bool = props.get(LCSS.DIRECTION, LCSS.BOTH) == LCSS.HORIZONTAL
	var bar: ScrollBar = _sc.get_h_scroll_bar() if horizontal else _sc.get_v_scroll_bar()
	var max_scroll: float = bar.max_value - bar.page
	if max_scroll <= 0.0:
		_at_start = true
		_at_end = false
		return   # o conteúdo cabe, não há o que rolar

	var threshold: float = props.get(LCSS.EDGE_THRESHOLD, 0)
	var at_start: bool = bar.value <= threshold
	var at_end: bool = bar.value >= max_scroll - threshold
	if at_start and not _at_start:
		emit_event("reached_start")
	if at_end and not _at_end:
		emit_event("reached_end")
	_at_start = at_start
	_at_end = at_end
#endregion
