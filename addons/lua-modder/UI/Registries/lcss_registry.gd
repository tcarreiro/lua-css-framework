class_name LCSSRegistry extends RefCounted

var _stylesheets: Array[LCSSStyleSheet] = []

# --- cache de resolução ---------------------------------------------------------------------------------
# O estilo de um componente depende só das classes dele e das classes dos ANCESTRAIS que as regras citam.
# Então componentes com o mesmo "conjunto relevante" compartilham o mesmo estilo resolvido.
var _resolve_cache: Dictionary[String, LCSSStyle] = {}
var _index_dirty := true
var _known_classes: Dictionary[StringName, bool] = {}     # classes citadas em QUALQUER seletor
var _ancestor_classes: Dictionary[StringName, bool] = {}  # classes citadas em trechos NÃO finais (os ancestrais)
var _ancestor_wildcard := false                           # há trecho de ancestral sem classe: casa com qualquer ancestral


func register(text: String) -> LCSSStyleSheet:
	# Parses lcss text into stylesheet and caches it
	var stylesheet := LCSSParser.parse(text)
	return register_stylesheet(stylesheet)


func register_file(path: String) -> LCSSStyleSheet:
	# Reads the file at 'path', extract its content and sends it to register()
	if not FileAccess.file_exists(path):
		push_error("[LCSSRegistry] arquivo não encontrado: '%s'" % path)
		return null

	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("[LCSSRegistry] não foi possível abrir o arquivo: '%s'" % path)
		return null

	return register(file.get_as_text())


func register_stylesheet(stylesheet: LCSSStyleSheet) -> LCSSStyleSheet:
	if stylesheet == null:
		return
	_stylesheets.append(stylesheet)
	_invalidate_cache()
	return stylesheet


func unregister(stylesheet: LCSSStyleSheet) -> void:
	_stylesheets.erase(stylesheet)
	_invalidate_cache()


func clear() -> void:
	_stylesheets.clear()
	_invalidate_cache()


func get_stylesheets() -> Array[LCSSStyleSheet]:
	return _stylesheets.duplicate()


func get_stylesheet_count() -> int:
	return _stylesheets.size()


#region Cache de resolução
func get_cached_style(key: String) -> LCSSStyle:
	return _resolve_cache.get(key)


func cache_style(key: String, style: LCSSStyle) -> void:
	_resolve_cache[key] = style


func _invalidate_cache() -> void:
	_resolve_cache.clear()
	LCSSResolver.invalidate()
	_index_dirty = true


## Chave do cache: as classes do componente QUE ALGUMA REGRA CITA (as outras não mudam o resultado) mais, se
## existirem regras com ancestral, as classes relevantes de cada ancestral, do mais próximo para cima.
## Ancestral sem nenhuma classe relevante nunca casa com nada, então não entra na chave.
func cache_key_for(component: LuaComponent) -> String:
	_ensure_index()
	var own := PackedStringArray()
	for style_class in component.style_classes:
		if _known_classes.has(style_class):
			own.append(String(style_class))
	own.sort()
	var key := " ".join(own)

	if _ancestor_classes.is_empty() and not _ancestor_wildcard:
		return key

	var ancestors := 0
	var node := component.get_parent()
	while node != null:
		var ancestor := node as LuaComponent
		if ancestor != null:
			ancestors += 1
			var relevant := PackedStringArray()
			for style_class in ancestor.style_classes:
				if _ancestor_classes.has(style_class):
					relevant.append(String(style_class))
			if not relevant.is_empty():
				relevant.sort()
				key += "<" + " ".join(relevant)
		node = node.get_parent()
	if _ancestor_wildcard:
		key += "#%d" % mini(ancestors, 8)   # um trecho sem classe casa com "qualquer ancestral": conta quantos há
	return key


## Há regra com combinador de descendente? Se não, o estilo de um componente nunca depende dos pais dele.
func has_ancestor_rules() -> bool:
	_ensure_index()
	return not _ancestor_classes.is_empty() or _ancestor_wildcard


## As classes de `classes` que alguma regra usa como ANCESTRAL, ordenadas e juntas ("" se nenhuma). Quando isto
## muda num componente, os descendentes dele podem mudar de estilo; quando não muda, não precisam ser refeitos.
func ancestor_signature(classes: Array[StringName]) -> String:
	_ensure_index()
	if _ancestor_classes.is_empty():
		return ""
	var relevant := PackedStringArray()
	for style_class in classes:
		if _ancestor_classes.has(style_class):
			relevant.append(String(style_class))
	relevant.sort()
	return " ".join(relevant)


func _ensure_index() -> void:
	if not _index_dirty:
		return
	_index_dirty = false
	_known_classes.clear()
	_ancestor_classes.clear()
	_ancestor_wildcard = false
	for sheet in _stylesheets:
		for style_class: LCSSStyleClass in sheet.get_style_classes():
			var last := style_class.selectors.size() - 1
			for i in style_class.selectors.size():
				var selector := style_class.selectors[i]
				for name in selector.classes:
					_known_classes[name] = true
					if i < last:
						_ancestor_classes[name] = true
				if i < last and selector.classes.is_empty():
					_ancestor_wildcard = true
#endregion


# as of now, it returns the first found. What would happen if two
# equally named keyframes are registered?
func find_keyframes(anim_name: StringName) -> LCSSKeyframes:
	for i in range(get_stylesheet_count() - 1, -1, -1):
		var found: LCSSKeyframes = _stylesheets[i].get_keyframes().get(anim_name)
		if found != null:
			return found
	return null

# as of now, it returns the first found. What would happen if two
# equally named style classes are registered?
#func find_style_classes(style_class_name: StringName) -> LCSSStyleClass:
	#for i in range(get_stylesheet_count() - 1, -1, -1):
		#var found: Variant = _stylesheets[i].get_style_classes()
		#.find_custom(func(sc: LCSSStyleClass): return sc.token)
		#pass
	#return null
