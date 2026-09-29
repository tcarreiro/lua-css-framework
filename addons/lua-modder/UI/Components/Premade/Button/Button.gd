extends LuaComponent

@onready var _button: Button = %Button

func get_schema() -> Dictionary:
	return {
		"name": "Button",
		"props": {"label": {"type": TYPE_STRING, "default": ""}, "disabled": {"type": TYPE_BOOL, "default": false}},
		"events": ["pressed", "mouse_entered", "mouse_exited"],
	}

func _component_ready() -> void:
	forward_signal(_button.pressed, "pressed")
	forward_signal(_button.mouse_entered, "mouse_entered")
	forward_signal(_button.mouse_exited, "mouse_exited")

func _apply_prop(key: String, value: Variant) -> void:
	match key:
		"label": _button.text = value
		"disabled": _button.disabled = value
