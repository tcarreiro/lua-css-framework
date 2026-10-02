extends LuaComponent

@onready var body: VBoxContainer = %Body

func get_schema() -> Dictionary:
	return {
		"name": "Body",
		"props": {"gap": {"type": TYPE_INT, "default": 4}},
		"slots": {"default": "%Body"},
	}


func _apply_prop(key: String, value: Variant) -> void:
	if key == "gap":
		if not value is int or value < 0:
			return
		body.add_theme_constant_override("separation", value)
	else:
		super._apply_prop(key, value)
