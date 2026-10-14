@tool
class_name LCSSSemanticValidator extends RefCounted


func validate_declaration(property_name: String, value_text: String) -> Dictionary:
	var catalog: Dictionary = ComponentProps._catalog()
	var property_key := StringName(property_name)
	var resolved_key: StringName = &""

	if catalog.has(property_key):
		resolved_key = property_key
	else:
		var candidates: Array[StringName] = []

		for key: Variant in catalog.keys():
			candidates.append(StringName(key))

		candidates.sort_custom(
			func(a: StringName, b: StringName) -> bool:
				return str(a).length() > str(b).length()
		)

		for candidate: StringName in candidates:
			if property_name.ends_with("_" + str(candidate)):
				resolved_key = candidate
				break

	if resolved_key == &"":
		return {"message": "Unknown property: '%s'." % property_name}

	if not catalog.has(resolved_key):
		return {}

	var definition: Dictionary = catalog[resolved_key]
	var options: Array = definition.get(ComponentProps.OPTIONS, [])

	if not options.is_empty():
		var value := value_text.strip_edges()
		var is_valid := false

		for option: Variant in options:
			if value == str(option):
				is_valid = true
				break

		if not is_valid:
			var allowed_values: Array[String] = []

			for option: Variant in options:
				allowed_values.append(str(option))

			return {
				"message": "Invalid value '%s' for property '%s'. Expected one of: %s." % [
					value, property_name, ", ".join(allowed_values)
				]
			}

	return {}


func validate_stylesheet(stylesheet: LCSSStyleSheetNode) -> Array[Dictionary]:
	var diagnostics: Array[Dictionary] = []

	for node: Variant in stylesheet.nodes:
		if node is LCSSRuleNode:
			_validate_declarations(node.declarations, diagnostics)
		elif node is LCSSKeyframesNode:
			for frame: LCSSRuleNode in node.frames:
				_validate_declarations(frame.declarations, diagnostics)

	return diagnostics


func _validate_declarations(declarations: Array, diagnostics: Array[Dictionary]) -> void:
	for declaration: LCSSDeclarationNode in declarations:
		var result := validate_declaration(declaration.property_name, declaration.value_text)

		if result.is_empty():
			continue

		diagnostics.append({
			"message": result["message"],
			"offset": declaration.start_offset,
			"line": declaration.line,
			"column": declaration.column,
		})

func _resolve_property(property_name: String) -> Dictionary:
	var catalog: Dictionary = ComponentProps._catalog()
	var property_key := StringName(property_name)

	# Exact match: standard property.
	if catalog.has(property_key):
		return {
			"name": property_key,
			"definition": catalog[property_key]
		}

	# Exact match: base property.
	if property_key in ComponentProps.BASE:
		return {
			"name": property_key,
			"definition": {}
		}

	# Custom property: prefix_standard_property.
	# Prefer the longest matching suffix.
	var candidates: Array[StringName] = []

	for key: Variant in catalog.keys():
		candidates.append(StringName(key))

	for key: Variant in ComponentProps.BASE:
		var base_key := StringName(key)
		if not candidates.has(base_key):
			candidates.append(base_key)

	candidates.sort_custom(
		func(a: StringName, b: StringName) -> bool:
			return str(a).length() > str(b).length()
	)

	for candidate: StringName in candidates:
		var suffix := "_" + str(candidate)

		if property_name.ends_with(suffix):
			var definition: Dictionary = {}

			if catalog.has(candidate):
				definition = catalog[candidate]

			return {
				"name": candidate,
				"definition": definition
			}

	return {}
