extends LuaComponent


func get_schema() -> Dictionary:
	return {
		"name": "RichTextLabel",
		"props": {
			"text": {"type": TYPE_STRING, "default": ""},
			"bbcode_enabled": {"type": TYPE_BOOL, "default": true},
			"autowrap": {"type": TYPE_STRING_NAME, "default": "word"},
			"fit_content": {"type": TYPE_BOOL, "default": true},
			"scroll_active": {"type": TYPE_BOOL, "default": true},
			"scroll_following": {"type": TYPE_BOOL, "default": false},
			"selection_enabled": {"type": TYPE_BOOL, "default": false},
		},
	}


func _setup_style_target() -> void:
	_style_target.register_property(&"font_color", self)
	_style_target.register_property(&"font_size", self)
	_style_target.register_property(&"outline_color", self)
	_style_target.register_property(&"outline_size", self)
	_style_target.register_property(&"shadow_color", self)
	_style_target.register_property(&"shadow_size", self)
	_style_target.register_property(&"shadow_offset", self)
	_style_target.register_property(&"line_separation", self)


func _apply_prop(key: String, value: Variant) -> void:
	match key:
		"text":
			self.text = value
		"bbcode_enabled":
			self.bbcode_enabled = value
		"autowrap":
			self.autowrap_mode = _parse_autowrap_mode(value)
		"fit_content":
			self.fit_content = value
		"scroll_active":
			self.scroll_active = value
		"scroll_following":
			self.scroll_following = value
		"selection_enabled":
			self.selection_enabled = value


func _apply_style_property(property: StringName, value: Variant, target: Node, style_box: StyleBoxFlat = null) -> void:
	match property:
		&"font_color":
			add_theme_color_override("default_color", LuaHelper.parse_color(value))
		&"font_size":
			add_theme_font_size_override("normal_font_size", int(value))
			add_theme_font_size_override("bold_font_size", int(value))
			add_theme_font_size_override("bold_italics_font_size", int(value))
			add_theme_font_size_override("italics_font_size", int(value))
			add_theme_font_size_override("mono_font_size", int(value))
		_:
			super._apply_style_property(property, value, target, style_box)


func _parse_autowrap_mode(value: StringName) -> TextServer.AutowrapMode:
	match value:
		&"off":
			return TextServer.AUTOWRAP_OFF
		&"word":
			return TextServer.AUTOWRAP_WORD
		&"word_smart":
			return TextServer.AUTOWRAP_WORD_SMART
		&"char":
			return TextServer.AUTOWRAP_ARBITRARY
		_:
			return TextServer.AUTOWRAP_WORD
