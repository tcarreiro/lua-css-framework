extends LuaComponent

@onready var _items: LuaFlowBox = %Items


func get_schema() -> Dictionary:
	return {
		"name": "Scroll",
		"props": {
			"direction": {"type": TYPE_STRING, "default": "both"},  # "vertical" | "horizontal" | "both"
			"content_margin": {"type": TYPE_NIL, "default": null},       # distância conteúdo <-> scrollbar
			"scrollbar_width": {"type": TYPE_INT, "default": 16},
			"track_color": {"type": TYPE_COLOR, "default": Color(0, 0, 0, 0.1)},
			"grabber_color": {"type": TYPE_COLOR, "default": Color(1, 1, 1, 0.3)},
			"grabber_hover_color": {"type": TYPE_COLOR, "default": Color(1, 1, 1, 0.3)},
			"grabber_pressed_color": {"type": TYPE_COLOR, "default": Color(1, 1, 1, 0.3)},
			"gap": {"type": TYPE_INT, "default": 4},
		},
		"slots": {"default": "%Items"},
	}


func _apply_prop(key: String, value: Variant) -> void:
	print(key, value)
	match key:
		"direction":
			self.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO if value != "vertical" else ScrollContainer.SCROLL_MODE_DISABLED
			self.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO if value != "horizontal" else ScrollContainer.SCROLL_MODE_DISABLED
		"content_margin":
			var v := LuaHelper.parse_distributable(value)
			add_theme_constant_override("margin_left", int(v[0]))
			add_theme_constant_override("margin_top", int(v[1]))
			add_theme_constant_override("margin_right", int(v[2]))
			add_theme_constant_override("margin_bottom", int(v[3]))
		"scrollbar_width", "track_color", "grabber_color", "grabber_hover_color", "grabber_pressed_color":
			_refresh_scrollbar_style()
		"gap":
			_items.add_theme_constant_override("separation", value)
		_:
			super._apply_prop(key, value)


## Reconstrói o StyleBoxFlat das 3 partes da scrollbar (track/grabber/grabber
## hover/pressed) e reaplica nas duas barras (H e V), como o Godot já
## permite via override direto no próprio ScrollContainer.
func _refresh_scrollbar_style() -> void:
	var width: int = props.get("scrollbar_width", 12)
	var track := StyleBoxFlat.new()
	track.bg_color = props.get("track_color", Color(0, 0, 0, 0.1))
	track.content_margin_left = width
	track.content_margin_right = width

	var grabber := StyleBoxFlat.new()
	grabber.bg_color = props.get("grabber_color", Color(1, 1, 1, 0.3))
	grabber.corner_radius_top_left = width / 2
	grabber.corner_radius_top_right = width / 2
	grabber.corner_radius_bottom_left = width / 2
	grabber.corner_radius_bottom_right = width / 2

	var grabber_hover := grabber.duplicate()
	grabber_hover.bg_color = props.get("grabber_hover_color", grabber.bg_color)

	var grabber_pressed := grabber.duplicate()
	grabber_pressed.bg_color = props.get("grabber_pressed_color", grabber.bg_color)

	for slot in ["scroll", "scroll_focus"]:
		add_theme_stylebox_override(slot, track)
	for slot in ["grabber", "grabber_highlight"]:
		add_theme_stylebox_override(slot, grabber)
	add_theme_stylebox_override("grabber_pressed", grabber_pressed)
