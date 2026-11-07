extends Div
## Repeat: um Div cujos filhos vêm de uma lista reativa.
##
##   Repeat{
##     gap = 6,
##     items = UI.bind(store, "gauntlets"),          -- lista (Array) vinda de uma store
##     render_item = function(item, index)           -- index começa em 0 (como os Array do Godot)
##       return Button{ label = item.name }
##     end,
##   }
##
## Quando `items` muda, só os índices cujo item mudou são recriados (ver LuaRepeatBuilder): o resto dos filhos
## continua como está. Lista igual à anterior (por valor): nada é refeito.
## render_item tem de ser função de (item, index); se o que ele desenha depende de outro estado, use UI.bind.
## O Repeat é dono dos próprios filhos: `children` estáticos são descartados na primeira montagem.

var _builder := LuaRepeatBuilder.new()


func get_schema() -> Dictionary:
	var schema := super.get_schema()
	schema["name"] = "Repeat"
	schema["props"]["items"] = {"type": "array", "default": []}
	schema["hooks"] = ["render_item"]
	return schema


func _apply_prop(key: String, value: Variant) -> void:
	if key == "items":
		_builder.sync(_items, value if value is Array else [], handlers.get("render_item", Callable()))
		return
	super._apply_prop(key, value)
