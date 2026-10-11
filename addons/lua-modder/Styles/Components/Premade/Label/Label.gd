extends LuaComponent

## A raiz é um Label, mas o script herda de LuaComponent (Control): Variant resolve em runtime.
@onready var _label: Variant = self


func get_schema() -> Dictionary:
	var names: Array = [ComponentProps.TEXT, ComponentProps.WIDTH, ComponentProps.HEIGHT,
			ComponentProps.MAX_WIDTH, ComponentProps.MAX_HEIGHT]
	names.append_array(ComponentProps.TEXT_LAYOUT)
	names.append_array(ComponentProps.LABEL_ONLY)
	names.append_array(ComponentProps.FONT)
	names.append_array(ComponentProps.TEXT_SHADOW)
	return {"name": "Label", "props": ComponentProps.pick(names, {ComponentProps.AUTOWRAP: "off"})}


func _ready() -> void:
	_style_target.register_group(ComponentProps.FONT, self)
	_style_target.register_group(ComponentProps.TEXT_SHADOW, self)
	_style_target.register_property(ComponentProps.LINE_SPACING, self)
	_style_target.register_property(ComponentProps.PARAGRAPH_SPACING, self)
	super._ready()


func _apply_prop(key: String, value: Variant) -> void:
	match StringName(key):
		ComponentProps.TEXT:
			_label.text = str(value)
		ComponentProps.TEXT_ALIGN:
			_label.horizontal_alignment = ComponentProps.H_ALIGNS.get(StringName(str(value)), HORIZONTAL_ALIGNMENT_LEFT)
		ComponentProps.TEXT_VALIGN:
			_label.vertical_alignment = ComponentProps.V_ALIGNS.get(StringName(str(value)), VERTICAL_ALIGNMENT_TOP)
		ComponentProps.AUTOWRAP:
			_label.autowrap_mode = ComponentProps.AUTOWRAP_MODES.get(StringName(str(value)), TextServer.AUTOWRAP_OFF)
		ComponentProps.UPPERCASE:
			_label.uppercase = bool(value)
		ComponentProps.TEXT_OVERFLOW:
			_label.text_overrun_behavior = ComponentProps.TEXT_OVERFLOWS.get(StringName(str(value)), TextServer.OVERRUN_NO_TRIMMING)
		ComponentProps.CLIP_TEXT:
			_label.clip_text = bool(value)
		ComponentProps.MAX_LINES:
			_label.max_lines_visible = int(value)
		ComponentProps.LINES_SKIPPED:
			_label.lines_skipped = int(value)
		ComponentProps.VISIBLE_CHARACTERS:
			_label.visible_characters = int(value)
		ComponentProps.VISIBLE_RATIO:
			_label.visible_ratio = float(value)
		ComponentProps.AUTO_FONT_SIZE:
			_label.resize_font_to_fit = bool(value)
		ComponentProps.MIN_FONT_SIZE:
			_label.minimum_font_size = int(value)
		ComponentProps.MAX_FONT_SIZE:
			_label.maximum_font_size = int(value)
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
