extends LuaComponent

@onready var _body: VBoxContainer = %Body

func get_schema() -> Dictionary:
	return {
		"name": "Body",
		"props": ComponentProps.pick([ComponentProps.GAP], {ComponentProps.GAP: 4}),
		"slots": {"default": "%Body"},
	}


func _apply_prop(key: String, value: Variant) -> void:
	match StringName(key):
		ComponentProps.GAP:
			_body.add_theme_constant_override("separation", maxi(int(value), 0))
		_:
			super._apply_prop(key, value)
