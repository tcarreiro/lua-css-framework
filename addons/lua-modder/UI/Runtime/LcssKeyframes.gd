class_name LCSSKeyframes extends RefCounted
## Quadros de um @keyframes: offset de 0 a 1 -> propriedades.

var frames: Array[Dictionary] = []   # { "offset": float, "properties": Dictionary }


func add_frame(offset: float, properties: Dictionary) -> void:
	frames.append({"offset": offset, "properties": properties})
	frames.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.offset < b.offset)


func property_names() -> Array[StringName]:
	var names: Array[StringName] = []
	for frame in frames:
		for p in frame.properties:
			if not names.has(p):
				names.append(p)
	return names


## [{ offset, value }] em ordem.
func frames_for(property: StringName) -> Array:
	var out: Array = []
	for frame in frames:
		if frame.properties.has(property):
			out.append({"offset": frame.offset, "value": frame.properties[property]})
	return out


func _to_string() -> String:
	var msg := []
	for frame in frames:
		msg.append(frame)
	return "\n".join(msg)
