class_name LCSSAppliers extends RefCounted
## Handler único usado por TODO componente que registra propriedades em um
## LCSSStyleTarget. Sabe COMO cada propriedade LCSS vira Godot de verdade;
## o componente só declara ONDE (via register_property), nunca COMO.

static func apply(property: StringName, value: Variant, target: Node) -> void:
	match property:
		"margin", "padding":
			_apply_box_constants(target as MarginContainer, value)
		"background_color", "border_color", "border_width", "border_radius", \
		"drop_shadow_color", "drop_shadow_size", "drop_shadow_offset":
			_apply_stylebox_field(target as Control, property, value)
		"font_color", "font_size", "outline_color", "outline_size", \
		"label_font_color", "label_font_size", "label_outline_color", "label_outline_size":
			_apply_text_style(target as Control, property, value)
		_:
			push_warning("[LCSSAppliers] propriedade sem applier: '%s'" % property)


static func _apply_box_constants(node: MarginContainer, value: Variant) -> void:
	if node == null or value == null or (value is Array and value == []):
		return
	var v: Array = LuaHelper.parse_distributable(value)
	if v.size() == 1:
		v = [v[0], v[0], v[0], v[0]]
	node.add_theme_constant_override("margin_left", int(v[0]))
	node.add_theme_constant_override("margin_top", int(v[1]))
	node.add_theme_constant_override("margin_right", int(v[2]))
	node.add_theme_constant_override("margin_bottom", int(v[3]))


## Um StyleBoxFlat próprio por Panel/PanelContainer, guardado como meta NO
## PRÓPRIO node — assim morre junto quando o node for liberado.
static func _apply_stylebox_field(target: Control, property: StringName, value: Variant) -> void:
	if target == null or value == null:
		return
	var box: StyleBoxFlat
	if target.has_meta("_lcss_box"):
		box = target.get_meta("_lcss_box")
	else:
		box = StyleBoxFlat.new()
		target.set_meta("_lcss_box", box)
		target.add_theme_stylebox_override("panel", box)

	match property:
		"background_color": box.bg_color = value
		"border_color": box.border_color = value
		"border_width":
			var w := int(value) if not (value is Array) else int(value[0])
			box.border_width_left = w; box.border_width_top = w
			box.border_width_right = w; box.border_width_bottom = w
		"border_radius":
			var r := int(value) if not (value is Array) else int(value[0])
			box.corner_radius_top_left = r; box.corner_radius_top_right = r
			box.corner_radius_bottom_left = r; box.corner_radius_bottom_right = r
		"drop_shadow_color": box.shadow_color = value
		"drop_shadow_size": box.shadow_size = int(value)
		"drop_shadow_offset":
			var v := LuaHelper.parse_distributable(value)
			box.shadow_offset = Vector2(v[0], v[1])


## Um único applier pra "cor/tamanho de fonte, com ou sem prefixo label_" —
## o prefixo só decide QUAL alvo foi registrado, não muda o que é aplicado.
static func _apply_text_style(target: Control, property: StringName, value: Variant) -> void:
	match property:
		"font_color", "label_font_color":
			target.add_theme_color_override("font_color", value)
		"outline_color", "label_outline_color":
			target.add_theme_color_override("font_outline_color", value)
		"font_size", "label_font_size":
			target.add_theme_font_size_override("font_size", int(value))
		"outline_size", "label_outline_size":
			target.add_theme_font_size_override("font_outline_size", int(value))
