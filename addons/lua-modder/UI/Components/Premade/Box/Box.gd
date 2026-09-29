extends LuaComponent

@onready var _items: BoxContainer = %Items
@onready var _padding: MarginContainer = %Padding

func get_schema() -> Dictionary:
	return {
		"name": "Box",
		"props": {
			"direction": {"type": TYPE_STRING, "default": "column"},  # "row" | "column"
			"gap": {"type": TYPE_INT, "default": 0},
		},
		"slots": {"default": "%Items"},
	}
 
func _apply_prop(key: String, value: Variant) -> void:
	match key:
		"direction": _items.vertical = (value != "row")
		"gap": _items.add_theme_constant_override("separation", value)
