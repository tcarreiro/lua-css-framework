extends Node
## Autoload: ComponentRegistry  (registre ANTES do bridge de UI)
##
## Componentes vindos de cena (.tscn) e de Lua (UI.defineComponent) viram a mesma
## coisa aqui: uma "definição" { name, kind, schema, scene | render }.
## Quem consome (Lua ou GDScript) só conhece o nome.

signal component_registered(component_name: String)

enum Kind { SCENE, LUA }

## Pastas escaneadas no boot. Projetos/mods podem chamar scan_directory() depois.
const SCAN_PATHS: Array[String] = ["res://addons/lua-modder/Styles/Components/Premade/"]
const MAX_DEPTH := 64

## Props que TODO componente aceita (aplicadas pela base LuaComponent).
const BASE_PROPS := {
	"id": {"type": TYPE_STRING, "default": ""},
	"class": {"type": TYPE_STRING, "default": ""},
	"visible": {"type": TYPE_BOOL, "default": true},
	"tooltip": {"type": TYPE_STRING, "default": ""},
	"disabled": {"type": TYPE_BOOL, "default": false},
}

const _TYPE_NAMES := {
	"any": TYPE_NIL, "string": TYPE_STRING, "int": TYPE_INT, "float": TYPE_FLOAT,
	"number": TYPE_FLOAT, "bool": TYPE_BOOL, "color": TYPE_COLOR, "vector2": TYPE_VECTOR2,
	"array": TYPE_ARRAY, "dict": TYPE_DICTIONARY, "object": TYPE_OBJECT,
}

var _defs: Dictionary = {}   # String -> Dictionary
var _refs: Dictionary = {}   # String -> WeakRef(LuaComponent)


func _init() -> void:
	for path in SCAN_PATHS:
		scan_directory(path)


#region Registration
## Escaneia uma pasta (recursivo) e registra toda cena cuja raiz herde LuaComponent.
func scan_directory(path: String, recursive := true) -> int:
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("[ComponentRegistry] pasta inexistente: %s" % path)
		return 0
	var count := 0
	if recursive:
		for sub in dir.get_directories():
			count += scan_directory(path.path_join(sub), true)
	for file in dir.get_files():
		# no export os arquivos aparecem como "x.tscn.remap"
		var real := file.trim_suffix(".remap")
		if real.get_extension() in ["tscn", "scn"]:
			if register_scene_path(path.path_join(real)):
				count += 1
	return count

# API to manually register scenes as components
func register_scene_path(path: String, name_override := "") -> bool:
	var scene := load(path) as PackedScene
	if scene == null:
		push_error("[ComponentRegistry] não foi possível carregar %s" % path)
		return false
	return register_scene(scene, name_override, path)


func register_scene(scene: PackedScene, name_override := "", source := "") -> bool:
	var probe := scene.instantiate()
	if not probe is LuaComponent:
		push_error("[ComponentRegistry] raiz de '%s' precisa herdar LuaComponent" % source)
		probe.free()
		return false
	var schema := normalize_schema(probe.get_schema())
	probe.free()

	var component := name_override
	if component == "":
		component = schema.get("name", "")
	if component == "" and source != "":
		component = source.get_file().get_basename()
	if component == "":
		push_error("[ComponentRegistry] componente sem nome (%s)" % source)
		return false
	
	return _register({
		"name": component, "kind": Kind.SCENE, "schema": schema,
		"scene": scene, "source": source,
	})


## `definition` = tabela Lua já normalizada: { props, events, hooks, methods, slots, render }
func register_lua(component: String, definition: Dictionary, lua: LuaState) -> bool:
	var render := LuaHelper.make_callable(definition.get("render"))
	if not render.is_valid():
		push_error("[ComponentRegistry] '%s': definição Lua sem função `render`" % component)
		return false
	return _register({
		"name": component, "kind": Kind.LUA, "schema": normalize_schema(definition),
		"render": render, "source": lua,
	})


func _register(def: Dictionary) -> bool:
	var component: String = def.name
	if _defs.has(component):
		push_warning("[ComponentRegistry] '%s' já registrado (%s), ignorando." % [component, _defs[component].source])
		return false
	_defs[component] = def
	component_registered.emit(component)
	return true
#endregion


#region Queries
func has_component(component: String) -> bool:
	return _defs.has(component)

func get_names() -> Array:
	return _defs.keys()

func get_schema(component: String) -> Dictionary:
	return _defs.get(component, {}).get("schema", {})

static func get_prop_def(schema: Dictionary, key: String) -> Dictionary:
	if BASE_PROPS.has(key):
		return BASE_PROPS[key]
	return schema.get("props", {}).get(key, {})
#endregion


#region Element building (Lua -> UIElement)
## Separa a tabela crua do Lua em props / handlers / slots segundo o schema.
func make_element(component: String, raw: Dictionary) -> UIElement:
	var def: Dictionary = _defs.get(component, {})
	if def.is_empty():
		push_error("[ComponentRegistry] componente desconhecido: '%s'" % component)
		return null
	var schema: Dictionary = def.schema
	var el := UIElement.new(component)

	for key: String in raw:
		var value: Variant = raw[key]
		match key:
			"children":
				el.slots["default"] = _to_elements(value)
			"slots":
				if value is Dictionary:
					for slot_name in value:
						el.slots[str(slot_name)] = _to_elements(value[slot_name])
			"ref":
				el.ref = str(value)
			_:
				if key.begins_with("on_") and key.substr(3) in schema.events:
					el.handlers[key] = LuaHelper.make_callable(value)
				elif key in schema.hooks:
					el.handlers[key] = LuaHelper.make_callable(value)
				elif BASE_PROPS.has(key) or schema.props.has(key):
					el.props[key] = value
				else:
					push_warning("[ComponentRegistry] '%s' não declara '%s'" % [component, key])
					if key.begins_with("on_"):
						el.handlers[key] = LuaHelper.make_callable(value)
					else:
						el.props[key] = value
	return el


func _to_elements(value: Variant) -> Array:
	var out: Array = []
	if value is UIElement:
		out.append(value)
	elif value is Array:
		for item in value:
			if item is UIElement:
				out.append(item)
	return out
#endregion


#region Instantiation (UIElement -> Control)
func instantiate(el: UIElement, depth := 0) -> Control:
	if el == null:
		return null
	if depth > MAX_DEPTH:
		push_error("[ComponentRegistry] profundidade máxima excedida (render recursivo?) em '%s'" % el.component)
		return null
	var def: Dictionary = _defs.get(el.component, {})
	if def.is_empty():
		push_error("[ComponentRegistry] componente desconhecido: '%s'" % el.component)
		return null
	match def.kind:
		Kind.SCENE:
			return _instantiate_scene(def, el, depth)
		Kind.LUA:
			return _instantiate_lua(def, el, depth)
	return null


func _instantiate_scene(def: Dictionary, el: UIElement, depth: int) -> Control:
	var node := (def.scene as PackedScene).instantiate() as LuaComponent
	node.setup(el.component, resolve_props(def.schema, el.props), el.handlers, def.schema)
	for slot_name: String in el.slots:
		var host := node.get_slot(slot_name)
		if host == null:
			push_error("[ComponentRegistry] '%s' não tem o slot '%s'" % [el.component, slot_name])
			continue
		for child_el: UIElement in el.slots[slot_name]:
			var child := instantiate(child_el, depth + 1)
			if child:
				host.add_child(child)
	_track_ref(node, el.ref)
	return node


func _instantiate_lua(def: Dictionary, el: UIElement, depth: int) -> Control:
	# O render Lua recebe props (com defaults) + handlers (on_x / hooks) + children + slots
	var args := resolve_props(def.schema, el.props)
	args.merge(el.handlers)
	args["children"] = el.slots.get("default", [])
	var named := {}
	for slot_name: String in el.slots:
		if slot_name != "default":
			named[slot_name] = el.slots[slot_name]
	args["slots"] = named

	var result: Variant = (def.render as Callable).call(args)
	if not result is UIElement:
		push_error("[ComponentRegistry] render de '%s' deve retornar um componente (retornou %s)" % [el.component, result])
		return null
	if el.ref != "" and result.ref == "":
		result.ref = el.ref
	return instantiate(result, depth + 1)
#endregion


#region Refs (Lua -> métodos expostos)
func _track_ref(node: LuaComponent, ref: String) -> void:
	if ref == "":
		return
	_refs[ref] = weakref(node)
	node.tree_exited.connect(func():
		if _refs.get(ref) and _refs[ref].get_ref() == node:
			_refs.erase(ref))


func get_ref(ref: String) -> LuaComponent:
	var w: WeakRef = _refs.get(ref)
	return w.get_ref() if w else null


func call_method(ref: String, method: String, args: Array = []) -> Variant:
	var node := get_ref(ref)
	if node == null:
		push_error("[ComponentRegistry] ref '%s' não encontrada" % ref)
		return null
	return node.call_exposed(method, args)
#endregion


#region Schema / props helpers
static func normalize_schema(raw: Dictionary) -> Dictionary:
	var schema := {"name": str(raw.get("name", "")), "props": {}, "events": [], "hooks": [], "methods": [], "slots": {}}

	var raw_props: Variant = raw.get("props", {})
	if raw_props is Dictionary:
		for key in raw_props:
			var p: Variant = raw_props[key]
			var def := {}
			if p is Dictionary:
				def = p.duplicate()
			else:
				def = {"type": p}   # atalho: props = { label = "string" }
			var t: Variant = def.get("type", TYPE_NIL)
			def["type"] = _TYPE_NAMES.get(t, TYPE_NIL) if t is String else int(t)
			if not def.has("default"):
				def["default"] = type_convert(null, def.type) if def.type != TYPE_NIL and def.type != TYPE_OBJECT else null
			schema.props[str(key)] = def

	for list_key in ["events", "hooks", "methods"]:
		var raw_list: Variant = raw.get(list_key, [])
		if raw_list is Array:
			for item in raw_list:
				schema[list_key].append(str(item))

	var raw_slots: Variant = raw.get("slots", {})
	if raw_slots is Dictionary:        # cena: { nome: "%NodePath" }
		for key in raw_slots:
			schema.slots[str(key)] = str(raw_slots[key])
	elif raw_slots is Array:           # lua: só os nomes
		for item in raw_slots:
			schema.slots[str(item)] = ""
	return schema


## Props finais = BASE_PROPS + schema.props, com default e coerção de tipo.
static func resolve_props(schema: Dictionary, given: Dictionary) -> Dictionary:
	var out := {}
	var all_defs: Dictionary = BASE_PROPS.duplicate()
	all_defs.merge(schema.get("props", {}), true)
	for key: String in all_defs:
		var def: Dictionary = all_defs[key]
		if given.has(key):
			out[key] = coerce(given[key], def)
		else:
			if def.get("required", false):
				push_warning("[ComponentRegistry] prop obrigatória ausente: '%s'" % key)
			var d: Variant = def.get("default")
			out[key] = d.duplicate(true) if (d is Array or d is Dictionary) else d
	# props não declaradas (já avisadas em make_element) seguem adiante
	for key: String in given:
		if not out.has(key):
			out[key] = given[key]
	return out


static func coerce(value: Variant, def: Dictionary) -> Variant:
	if value == null:
		return def.get("default")
	var t: int = def.get("type", TYPE_NIL)
	if t == TYPE_NIL or t == TYPE_OBJECT or typeof(value) == t:
		return value
	if t == TYPE_VECTOR2 and value is Array and value.size() == 2:
		return Vector2(value[0], value[1])
	return type_convert(value, t)

#endregion
