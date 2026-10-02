class_name LuaFlowBox extends BoxContainer
## Slot de qualquer componente com filhos arbitrários (Div, Body...).
## Aplica sozinho o sizing "block vs flex" a cada filho que entra.

func _ready() -> void:
	child_entered_tree.connect(_on_child_entered)


func _on_child_entered(child: Node) -> void:
	if child is Control:
		_apply_flow_sizing(child)


func _apply_flow_sizing(child: Control) -> void:
	var has_explicit_width := child.custom_minimum_size.x > 0.0

	if vertical:
		# block: ocupa a linha inteira, a menos que tenha width (vira min-width)
		child.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN if has_explicit_width else Control.SIZE_FILL
		child.size_flags_vertical = Control.SIZE_FILL
	else:
		# flex: eixo principal já é fit-content por padrão do BoxContainer;
		# flex_grow (já tratado nas BASE_PROPS) cuida de quem deve crescer.
		child.size_flags_vertical = Control.SIZE_FILL
