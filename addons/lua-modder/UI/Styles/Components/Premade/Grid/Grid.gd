extends LuaStyledBox

@onready var _items: LuaGridBox = %Items


func get_schema() -> Dictionary:
	var names: Array = [LCSS.COLUMNS, LCSS.GAP, LCSS.COLUMN_GAP,
			LCSS.ROW_GAP, LCSS.FILL_CELLS]
	names.append_array(LuaStyledBox.box_names())
	return {
		"name": "Grid",
		"props": LCSS.pick(names, {LCSS.GAP: 4}),
		"slots": {"default": "%Items"},
	}


func _apply_prop(key: String, value: Variant) -> void:
	match StringName(key):
		LCSS.COLUMNS:
			_items.columns = maxi(int(value), 1)
		LCSS.GAP, LCSS.COLUMN_GAP, LCSS.ROW_GAP:
			_refresh_gaps()
		LCSS.FILL_CELLS:
			_items.fill = bool(value)
		_:
			super._apply_prop(key, value)


## column_gap e row_gap vencem o gap quando definidos. Lê de props: a ordem não importa.
func _refresh_gaps() -> void:
	var gap := maxi(int(props.get("gap", 0)), 0)
	var column: Variant = props.get("column_gap")
	var row: Variant = props.get("row_gap")
	_items.add_theme_constant_override("h_separation", maxi(int(column), 0) if column != null else gap)
	_items.add_theme_constant_override("v_separation", maxi(int(row), 0) if row != null else gap)
