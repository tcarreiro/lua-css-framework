@tool
class_name LCSSRuleNode extends LCSSSyntaxNode


var selectors: PackedStringArray = []
var declarations: Array[LCSSDeclarationNode] = []


func get_declaration(property_name: String) -> LCSSDeclarationNode:
	for declaration in declarations:
		if declaration.property_name == property_name:
			return declaration

	return null


func get_declarations(property_name: String) -> Array[LCSSDeclarationNode]:
	var result: Array[LCSSDeclarationNode] = []

	for declaration in declarations:
		if declaration.property_name == property_name:
			result.append(declaration)

	return result
