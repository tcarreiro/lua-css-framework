extends LuaComponent

@onready var _margin: MarginContainer = %Margin
@onready var _items: LuaFlowBox = %Items
@onready var _sc: Variant = self

var _at_start := true
var _at_end := false

func get_schema() -> Dictionary:
	# testados: GAP
	var names: Array = [
		ComponentProps.PADDING, ComponentProps.GAP,
		ComponentProps.WIDTH, ComponentProps.HEIGHT,
		ComponentProps.MAX_WIDTH, ComponentProps.MAX_HEIGHT,
		ComponentProps.DIRECTION, ComponentProps.SCROLLBAR_MODE,
		ComponentProps.FOLLOW_FOCUS, ComponentProps.EDGE_THRESHOLD,
		ComponentProps.SCROLL_HINT, ComponentProps.SCROLL_HINT_TILE,
		ComponentProps.DISPLAY
	]
	names.append_array(ComponentProps.PANEL)
	names.append_array(ComponentProps.SCROLLBAR)   # inclui scrollbar_gap e o raio por canto
	return {
		"name": "Scroll",
		"props": ComponentProps.pick(names, {ComponentProps.GAP: 4}),
		"events": ["scrolled", "reached_start", "reached_end", "scroll_started", "scroll_ended"],
		"methods": ["scroll_to_top", "scroll_to_bottom", "scroll_to_ref"],
		"slots": {"default": "%Items"},
	}


func _ready() -> void:
	_style_target.register_property(ComponentProps.PADDING, _margin)
	for prop in ComponentProps.SCROLLBAR:
		_style_target.register_property(prop, _sc)
	for prop in ComponentProps.PANEL:
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
		ComponentProps.DIRECTION, ComponentProps.SCROLLBAR_MODE:
			_refresh_scroll_modes()
		ComponentProps.WIDTH:
			if value != null and int(value) >= 0:
				custom_minimum_size.x = value
		ComponentProps.HEIGHT:
			if value != null and int(value) >= 0:
				custom_minimum_size.y = value
		ComponentProps.MAX_WIDTH:
			if value != null:
				custom_maximum_size.x = float(value)   # < 0 = sem limite (doc)
		ComponentProps.MAX_HEIGHT:
			if value != null:
				custom_maximum_size.y = float(value)
		ComponentProps.GAP:
			_items.add_theme_constant_override("separation", int(value))
		ComponentProps.FOLLOW_FOCUS:
			_sc.follow_focus = value
		ComponentProps.SCROLL_HINT:
			_sc.scroll_hint_mode = ComponentProps.HINT_MODES.get(StringName(value), ScrollContainer.SCROLL_HINT_MODE_DISABLED)
		ComponentProps.SCROLL_HINT_TILE:
			_sc.tile_scroll_hint = value
		ComponentProps.DISPLAY:
			_items.vertical = (value != ComponentProps.FLEX)
			_items.refresh_flow()
		_:
			super._apply_prop(key, value)


func _refresh_scroll_modes() -> void:
	var dir := StringName(props.get(ComponentProps.DIRECTION, ComponentProps.BOTH))
	var base: int = ComponentProps.SCROLL_MODES.get(
			StringName(props.get(ComponentProps.SCROLLBAR_MODE, ComponentProps.AUTO)), ScrollContainer.SCROLL_MODE_AUTO)
	var h_max := int(props.get(ComponentProps.MAX_WIDTH, -1)) >= 0
	var v_max := int(props.get(ComponentProps.MAX_HEIGHT, -1)) >= 0
	_sc.horizontal_scroll_mode = _axis_mode(dir != ComponentProps.VERTICAL, h_max, base)
	_sc.vertical_scroll_mode = _axis_mode(dir != ComponentProps.HORIZONTAL, v_max, base)
	_sc.scroll_horizontal_by_default = (dir == ComponentProps.HORIZONTAL)


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
	var horizontal: bool = props.get(ComponentProps.DIRECTION, ComponentProps.BOTH) == ComponentProps.HORIZONTAL
	var bar: ScrollBar = _sc.get_h_scroll_bar() if horizontal else _sc.get_v_scroll_bar()
	var max_scroll: float = bar.max_value - bar.page
	if max_scroll <= 0.0:
		_at_start = true
		_at_end = false
		return   # o conteúdo cabe, não há o que rolar

	var threshold: float = props.get(ComponentProps.EDGE_THRESHOLD, 0)
	var at_start: bool = bar.value <= threshold
	var at_end: bool = bar.value >= max_scroll - threshold
	if at_start and not _at_start:
		emit_event("reached_start")
	if at_end and not _at_end:
		emit_event("reached_end")
	_at_start = at_start
	_at_end = at_end
#endregion
