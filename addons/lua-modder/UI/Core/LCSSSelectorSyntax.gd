@tool
class_name LCSSSelectorSyntax extends RefCounted

const IDENTIFIER_PATTERN := "^[A-Za-z_][A-Za-z0-9_-]*$"

var _identifier_regex := RegEx.new()

func _init() -> void:
	_identifier_regex.compile(IDENTIFIER_PATTERN)


func parse(selector: String) -> Dictionary:
	var result := {
		"parts": [],
		"error": {},
	}

	if selector.strip_edges().is_empty():
		result["error"] = _error(selector, 0, "O seletor não pode estar vazio.")
		return result

	var parts: Array[Dictionary] = []
	var position := 0
	var length := selector.length()

	while position < length:
		position = _skip_whitespace(selector, position)

		if position >= length:
			break

		if selector[position] == ">":
			result["error"] = _error(selector, position, "O combinador '>' ainda não é suportado.")
			return result

		if selector[position] != ".":
			result["error"] = _error(selector, position, "Esperado '.' antes do nome da classe.")
			return result

		position += 1

		var class_start := position
		position = _read_identifier(selector, position)

		if position == class_start:
			result["error"] = _error(selector, class_start, "Esperado um nome de classe após '.'.")
			return result

		var classname := selector.substr(class_start, position - class_start)

		if not _is_valid_identifier(classname):
			result["error"] = _error(selector, class_start, "Invalid class name: '%s'." % classname)
			return result

		var classes: Array[StringName] = [StringName(classname)]

		var states: Array[StringName] = []

		while position < length and selector[position] == ":":
			position += 1

			var state_start := position
			position = _read_identifier(selector, position)

			if position == state_start:
				result["error"] = _error(selector, state_start, "Esperado um nome de estado após ':'.")
				return result

			var state_name := selector.substr(
				state_start,
				position - state_start
			)

			if not _is_valid_identifier(state_name):
				result["error"] = _error(selector, state_start, "Nome de estado inválido: '%s'." % state_name)
				return result

			states.append(StringName(state_name))

		parts.append({
			"classes": classes,
			"states": states,
		})

		if position >= length:
			break

		if not _is_whitespace(selector[position]):
			if selector[position] == ".":
				result["error"] = _error(
					selector,
					position,
					"Falta um espaço entre os seletores de classe."
				)
			else:
				result["error"] = _error(
					selector,
					position,
					"Caractere inesperado após o nome da classe."
				)
			return result

		position = _skip_whitespace(selector, position)

		if position < length and selector[position] == ">":
			result["error"] = _error(
				selector,
				position,
				"O combinador '>' ainda não é suportado."
			)
			return result

		if position < length and selector[position] != ".":
			result["error"] = _error(
				selector,
				position,
				"Esperado '.' antes do nome da classe."
			)
			return result

	if parts.is_empty():
		result["error"] = _error(
			selector,
			0,
			"Esperado um seletor de classe."
		)
		return result

	result["parts"] = parts
	return result


func _skip_whitespace(text: String, start: int) -> int:
	var position := start

	while position < text.length() and _is_whitespace(text[position]):
		position += 1

	return position


func _read_identifier(text: String, start: int) -> int:
	var position := start

	while position < text.length():
		if not _is_identifier_character(text[position]):
			break

		position += 1

	return position


func _is_identifier_character(character: String) -> bool:
	return (
		(character >= "a" and character <= "z")
		or (character >= "A" and character <= "Z")
		or (character >= "0" and character <= "9")
		or character == "_"
		or character == "-"
	)


func _is_valid_identifier(identifier: String) -> bool:
	return _identifier_regex.search(identifier) != null


func _is_whitespace(character: String) -> bool:
	return (
		character == " "
		or character == "\t"
		or character == "\n"
		or character == "\r"
	)


func _error(
	selector: String,
	offset: int,
	message: String
) -> Dictionary:
	return {
		"selector": selector,
		"offset": offset,
		"message": message,
	}
