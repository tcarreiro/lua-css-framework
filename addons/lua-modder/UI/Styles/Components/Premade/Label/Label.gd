extends LuaComponent

## A raiz é um Label, mas o script herda de LuaComponent (Control): Variant resolve em runtime.
@onready var _label: Variant = self


func get_schema() -> Dictionary:
	var names: Array = [LCSS.TEXT, LCSS.WIDTH, LCSS.HEIGHT,
			LCSS.MAX_WIDTH, LCSS.MAX_HEIGHT]
	names.append_array(LCSS.TEXT_LAYOUT)
	names.append_array(LCSS.LABEL_ONLY)
	names.append_array(LCSS.FONT)
	names.append_array(LCSS.TEXT_SHADOW)
	return {"name": "Label", "props": LCSS.pick(names, {LCSS.AUTOWRAP: "off"})}


func _ready() -> void:
	_style_target.register_group(LCSS.FONT, self)
	_style_target.register_group(LCSS.TEXT_SHADOW, self)
	_style_target.register_property(LCSS.LINE_SPACING, self)
	_style_target.register_property(LCSS.PARAGRAPH_SPACING, self)
	super._ready()


func _apply_prop(key: String, value: Variant) -> void:
	if not value:
		return
	match StringName(key):
		LCSS.TEXT:
			_label.text = str(value)
		LCSS.TEXT_ALIGN:
			_label.horizontal_alignment = LCSS.H_ALIGNS.get(StringName(str(value)), HORIZONTAL_ALIGNMENT_LEFT)
		LCSS.TEXT_VALIGN:
			_label.vertical_alignment = LCSS.V_ALIGNS.get(StringName(str(value)), VERTICAL_ALIGNMENT_TOP)
		LCSS.AUTOWRAP:
			_label.autowrap_mode = LCSS.AUTOWRAP_MODES.get(StringName(str(value)), TextServer.AUTOWRAP_OFF)
		LCSS.UPPERCASE:
			_label.uppercase = bool(value)
		LCSS.TEXT_OVERFLOW:
			_label.text_overrun_behavior = LCSS.TEXT_OVERFLOWS.get(StringName(str(value)), TextServer.OVERRUN_NO_TRIMMING)
		LCSS.CLIP_TEXT:
			_label.clip_text = bool(value)
		LCSS.MAX_LINES:
			_label.max_lines_visible = int(value)
		LCSS.LINES_SKIPPED:
			_label.lines_skipped = int(value)
		LCSS.VISIBLE_CHARACTERS:
			_label.visible_characters = int(value)
		LCSS.VISIBLE_RATIO:
			_label.visible_ratio = float(value)
		LCSS.AUTO_FONT_SIZE:
			_label.resize_font_to_fit = bool(value)
		LCSS.MIN_FONT_SIZE:
			_label.minimum_font_size = int(value)
		LCSS.MAX_FONT_SIZE:
			_label.maximum_font_size = int(value)
		LCSS.WIDTH:
			if int(value) >= 0: custom_minimum_size.x = value
		LCSS.HEIGHT:
			if int(value) >= 0: custom_minimum_size.y = value
		LCSS.MAX_WIDTH:
			custom_maximum_size.x = float(value)   # < 0 = sem limite
		LCSS.MAX_HEIGHT:
			custom_maximum_size.y = float(value)
		_:
			super._apply_prop(key, value)
