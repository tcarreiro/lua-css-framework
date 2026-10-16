class_name LCSSProperty extends RefCounted

var name: StringName
var value: Variant

func _init(_name: StringName, _value: Variant) -> void:
	name = _name
	value = _value


func _to_string() -> String:
	var sb := []
	sb.append("LCSSProperty(Name: %s"%[name])
	sb.append("Value: %s)"%[value])
	return ", ".join(sb)
