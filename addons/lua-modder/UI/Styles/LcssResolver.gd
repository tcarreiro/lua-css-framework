class_name LCSSResolver extends RefCounted

static var _index: Dictionary = {}                 # StringName -> Array (regras)
static var _universal: Array = []                  # regras cujo último trecho não tem classe
static var _built := false


static func invalidate() -> void:
	_built = false

## Estilo do componente: uma instância leve de um protótipo CACHEADO por conjunto de classes relevantes
## (ver LCSSRegistry.cache_key_for). Resolver de verdade (varrer todas as regras) só acontece na primeira vez
## que aquele conjunto aparece; 28 slots iguais custam UMA resolução, não 28.
static func resolve(component: LuaComponent, registry: LCSSRegistry) -> LCSSStyle:
	return LCSSStyle.instance_of(resolve_prototype(component, registry))


## O protótipo compartilhado (nunca altere o que ele devolve). Dois componentes com o mesmo protótipo têm o mesmo estilo.
static func resolve_prototype(component: LuaComponent, registry: LCSSRegistry) -> LCSSStyle:
	var key := registry.cache_key_for(component)
	var cached := registry.get_cached_style(key)
	if cached != null:
		return cached
	var prototype := _build(component, registry)
	registry.cache_style(key, prototype)
	return prototype


static func _build_index(registry: LCSSRegistry) -> void:
	_index.clear()
	_universal.clear()
	var order := 0
	for sheet in registry.get_stylesheets():
		for style_class: LCSSStyleClass in sheet.get_style_classes():
			style_class.sort_key = (style_class.get_specificity() << 20) | order
			order += 1   # mesma contagem do código antigo (conta toda regra)
			if style_class.selectors.is_empty():
				continue
			var last := style_class.selectors[style_class.selectors.size() - 1]
			if last.classes.is_empty():
				_universal.append(style_class)
			else:
				var key: StringName = last.classes[0]
				if not _index.has(key):
					_index[key] = []
				_index[key].append(style_class)
	_built = true


static func _build(component: LuaComponent, registry: LCSSRegistry) -> LCSSStyle:
	if not _built:
		_build_index(registry)
	
	var matched: Array[LCSSStyleClass] = []
	for style_class: LCSSStyleClass in _universal:
		if style_class.matches(component, false):
			matched.append(style_class)
	
	for cls in component.style_classes:
		for style_class: LCSSStyleClass in _index.get(cls, []):
			if style_class.matches(component, false):
				matched.append(style_class)
	
	matched.sort_custom(func(a: LCSSStyleClass, b: LCSSStyleClass) -> bool: return a.sort_key < b.sort_key)

	var style := LCSSStyle.new()
	for style_class in matched:
		var state := style_class.get_own_state()
		var target: LCSSStyle = style if state == &"" else style.ensure_state(state)
		for property: StringName in style_class.properties:
			target.set_property(property, (style_class.properties[property] as LCSSProperty).value)
	return style


## Estado declarado na ÚLTIMA parte do selector (":hover" em ".foo:hover").
static func _own_state(style_class: LCSSStyleClass) -> StringName:
	if style_class.selectors.is_empty():
		return &""
	var last = style_class.selectors[style_class.selectors.size() - 1]
	return last.state
