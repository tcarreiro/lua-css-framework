class_name LuaStyledBox extends LuaComponent
## Base de todo componente com wrapper visual: Margin > Background > Padding.
## Registra essas propriedades no LCSS automaticamente; quem herda só cuida
## do que é específico (o que entra dentro do slot/conteúdo).

@onready var _margin: MarginContainer = %Margin
@onready var _background: PanelContainer = %Background
@onready var _padding: MarginContainer = %Padding

const BOX_PROPS: Array[StringName] = [
	&"background_color", &"border_color", &"border_width", &"border_radius",
	&"drop_shadow_color", &"drop_shadow_size", &"drop_shadow_offset",
]


static func _base_schema_props() -> Dictionary:
	return {
		"margin": {"type": TYPE_NIL, "default": null},
		"padding": {"type": TYPE_NIL, "default": null},
		"background_color": {"type": TYPE_COLOR, "default": null},
		"border_color": {"type": TYPE_COLOR, "default": null},
		"border_width": {"type": TYPE_NIL, "default": null},
		"border_radius": {"type": TYPE_NIL, "default": null},
		"drop_shadow_color": {"type": TYPE_COLOR, "default": null},
		"drop_shadow_size": {"type": TYPE_INT, "default": null},
		"drop_shadow_offset": {"type": TYPE_NIL, "default": null},
	}


## Junta o schema base (margin/padding/background) com o específico do
## componente que herda. Uso: `LuaStyledBox.merge_schema({..., "props": {...}})`.
static func merge_schema(extra: Dictionary) -> Dictionary:
	var out := extra.duplicate(true)
	var props: Dictionary = _base_schema_props()
	if out.has("props"):
		props.merge(out["props"], true)
	out["props"] = props
	return out


func _ready() -> void:
	_style_target.register_property(&"margin", _margin)
	_style_target.register_property(&"padding", _padding)
	for prop in BOX_PROPS:
		_style_target.register_property(prop, _background)
	_setup_style_target()
	_bind_style_state_source(_style_state_source())
	_background.gui_input.connect(_on_background_gui_input)
	super._ready()


## Nó que dispara hover/focus/pressed. Default = o próprio %Background
## (serve pra Div). Componentes com uma superfície interativa própria
## (Button, Input) sobrescrevem para apontar pra ela.
func _style_state_source() -> Control:
	return _background


## Override point: componentes com propriedades próprias (ex: font_color
## do Button, indo pro %Btn em vez do %Background) registram aqui.
func _setup_style_target() -> void:
	pass


func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and is_style_state_active(&"disabled"):
			return
		_set_style_state(&"pressed", event.pressed)


static func strip_native_stylebox(control: Control, slots: Array[String]) -> void:
	var empty := StyleBoxEmpty.new()
	for slot in slots:
		control.add_theme_stylebox_override(slot, empty)
