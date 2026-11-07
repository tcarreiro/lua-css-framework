class_name LuaRepeatBuilder extends RefCounted
## Mantém os filhos de um Repeat/RepeatGrid em sincronia com a lista `items`, refazendo SÓ o que mudou.
##
## Compara por ÍNDICE e por VALOR: se items[i] é igual ao que foi renderizado ali da última vez, o nó fica como
## está (preserva hover, foco, animação, um arraste em curso); só os índices cujo item mudou são recriados, e a
## lista cresce ou encolhe no fim. Isso presume que render_item é função de (item, índice), que é o contrato do
## Repeat: se o que ele desenha depende de OUTRO estado, use UI.bind dentro do que ele devolve.
##
## Inserir/remover no MEIO desloca os itens seguintes, então refaz dali em diante (comparação é por índice).

var _started := false
var _seen: Array = []           # cópia de cada item como foi renderizado
var _nodes: Array[Node] = []    # nó de cada índice (null = render_item não devolveu um componente)


func sync(container: Node, items: Array, render_item: Callable) -> void:
	if not render_item.is_valid():
		push_warning("[Repeat] falta o hook render_item")
		return
	if not _started:
		_started = true
		for child in container.get_children():   # `children` estáticos: o Repeat é dono dos filhos
			_discard(container, child)

	var common := mini(items.size(), _seen.size())
	for i in common:
		if items[i] != _seen[i]:
			_replace(container, i, items[i], render_item)

	while _nodes.size() > items.size():   # a lista encolheu
		var removed: Node = _nodes.pop_back()
		_seen.pop_back()
		if removed != null:
			_discard(container, removed)

	for i in range(_nodes.size(), items.size()):   # a lista cresceu
		var node := _render(items[i], i, render_item)
		_nodes.append(node)
		_seen.append(_copy(items[i]))
		if node != null:
			container.add_child(node)


func _replace(container: Node, index: int, item: Variant, render_item: Callable) -> void:
	var old := _nodes[index]
	var node := _render(item, index, render_item)
	if node != null:
		container.add_child(node)
		container.move_child(node, old.get_index() if old != null else _position_of(index))
	if old != null:
		_discard(container, old)
	_nodes[index] = node
	_seen[index] = _copy(item)


## Posição de um item entre os filhos reais (os que falharam ao renderizar não ocupam lugar).
func _position_of(index: int) -> int:
	var position := 0
	for i in index:
		if _nodes[i] != null:
			position += 1
	return position


func _render(item: Variant, index: int, render_item: Callable) -> Node:
	var element: Variant = render_item.call(item, index)
	if not element is UIElement:
		push_warning("[Repeat] render_item deve retornar um componente (item %d)" % index)
		return null
	return ComponentRegistry.instantiate(element as UIElement)


func _discard(container: Node, node: Node) -> void:
	container.remove_child(node)
	if node is LuaComponent:
		(node as LuaComponent).dispose()
	else:
		node.queue_free()


func _copy(item: Variant) -> Variant:
	return item.duplicate(true) if (item is Dictionary or item is Array) else item
