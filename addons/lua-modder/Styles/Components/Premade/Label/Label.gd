extends LuaComponent

## A raiz é um Label, mas o script herda de LuaComponent (Control), então o
## analisador não enxerga .text. Variant resolve em runtime.
@onready var _label: Variant = self


func get_schema() -> Dictionary:
	var names: Array = [ComponentProps.TEXT]
	names.append_array(ComponentProps.FONT)
	return {
		"name": "Label",
		"props": ComponentProps.pick(names),
	}


func _ready() -> void:
	_style_target.register_group(ComponentProps.FONT, self)
	super._ready()


func _apply_prop(key: String, value: Variant) -> void:
	match StringName(key):
		ComponentProps.TEXT:
			_label.text = str(value)
		_:
			super._apply_prop(key, value)
