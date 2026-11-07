extends "res://addons/lua-modder/UI/Styles/Components/Premade/Grid/Grid.gd"
## RepeatGrid: um Grid cujos filhos vêm de uma lista reativa.
##
##   RepeatGrid{
##     gap = 6,
##     items = UI.bind(store, "gauntlets"),          -- lista (Array) vinda de uma store
##     render_item = function(item, index)           -- index começa em 0 (como os Array do Godot)
##       return Button{ label = item.name }
##     end,
##   }
##
## Quando `items` muda, TODOS os filhos são destruídos e `render_item` roda de novo para cada item.
## Se a lista chegar igual à anterior (comparação por valor), nada é refeito.
## O RepeatGrid é dono dos próprios filhos: `children` estáticos são descartados na primeira montagem.

const BUDGET_USEC := 6000
var _pending: Array = []
var _next := 0
var _loading: Control

var _build_id := 0
var _built := false
var _last_items: Array = []

var _t_start := 0
var _frames_start := 0
var _worst_step := 0

func get_schema() -> Dictionary:
	var schema := super.get_schema()
	schema["name"] = "RepeatGrid"
	schema["props"]["async"] = {"type": "bool", "default": false}
	schema["props"]["items"] = {"type": "array", "default": []}
	schema["hooks"] = ["render_item", "render_loading"]
	return schema


func _ready() -> void:
	set_process(false)
	super._ready()


func _apply_prop(key: String, value: Variant) -> void:
	if key == "items":
		_rebuild(value if value is Array else [])
		return
	super._apply_prop(key, value)


func _process(_delta: float) -> void:
	_build_step(false)


func _rebuild(items: Array) -> void:
	if _built and items == _last_items:
		return
	_built = true
	_last_items = items.duplicate(true)
	for child in _items.get_children():
		_items.remove_child(child)
		if child is LuaComponent:
			(child as LuaComponent).dispose()
		else:
			child.queue_free()
	if props["async"]:
		_hide_loading()
		_items.show()
		_pending = items      # uma construção nova substitui a anterior, sem precisar de id
		_next = 0
		_t_start = Time.get_ticks_usec()
		_frames_start = Engine.get_process_frames()
		_worst_step = 0
		_build_step(true)
		return
	
	var render_item: Callable = handlers.get("render_item", Callable())
	if not render_item.is_valid():
		push_warning("[Repeat] render_item hook missing")
		return
	for i in items.size():
		var el: Variant = render_item.call(items[i], i)
		if not el is UIElement:
			push_warning("[Repeat] render_item must return a LuaComponent (item %d)" % i)
			continue
		var node := ComponentRegistry.instantiate(el as UIElement)
		if node != null:
			_items.add_child(node)
			#if i == 0:
				#LuaComponent.debug_skip_style = true
	#LuaComponent.debug_skip_style = false


func _build_step(first: bool) -> void:
	var _step_t0 := Time.get_ticks_usec()
	var render_item: Callable = handlers.get("render_item", Callable())
	if not render_item.is_valid():
		_worst_step = maxi(_worst_step, Time.get_ticks_usec() - _step_t0)
		set_process(false)
		return
	var start := Time.get_ticks_usec()
	while _next < _pending.size():
		var el: Variant = render_item.call(_pending[_next], _next)
		_next += 1
		if el is UIElement:
			var node := ComponentRegistry.instantiate(el as UIElement)
			if node != null:
				_items.add_child(node)
		if Time.get_ticks_usec() - start >= BUDGET_USEC and _next < _pending.size():
			if first:
				_show_loading()
			_worst_step = maxi(_worst_step, Time.get_ticks_usec() - _step_t0)
			set_process(true)
			return
	set_process(false)
	_hide_loading()
	_items.show()
	print("[ASYNC] %d itens em %.0f ms, %d frames, pior lote %.2f ms" % [
	_pending.size(), (Time.get_ticks_usec() - _t_start) / 1000.0,
	Engine.get_process_frames() - _frames_start, _worst_step / 1000.0])

func _show_loading() -> void:
	_items.hide()
	var hook: Callable = handlers.get("render_loading", Callable())
	if _loading != null or not hook.is_valid():
		return
	var el: Variant = hook.call()
	if el is UIElement:
		_loading = ComponentRegistry.instantiate(el as UIElement)
		if _loading != null:
			var holder := _items.get_parent()
			holder.add_child(_loading)
			holder.move_child(_loading, _items.get_index())

func _hide_loading() -> void:
	if _loading != null:
		_loading.queue_free()
		_loading = null
