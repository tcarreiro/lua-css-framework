@tool
class_name LCSSSelectorValidator extends RefCounted

var _selector_syntax := LCSSSelectorSyntax.new()

func validate_selector(selector: String) -> Dictionary:
	var result := _selector_syntax.parse(selector)
	return result["error"]


func validate_selectors(selectors: PackedStringArray) -> Array[Dictionary]:
	var errors: Array[Dictionary] = []

	for index in range(selectors.size()):
		var error := validate_selector(selectors[index])

		if not error.is_empty():
			error["selector_index"] = index
			errors.append(error)

	return errors
