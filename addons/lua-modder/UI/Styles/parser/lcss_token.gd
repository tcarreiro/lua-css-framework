class_name LCSSToken extends RefCounted

var start_position: int
var end_position: int
var value: String
var kind: StringName #LCSS.KIND

func _init(_kind: StringName, _start: int, _end: int, _value: String) -> void:
	kind = _kind
	start_position = _start
	end_position = _end
	value = _value


func _to_string() -> String:
	var sb:= []
	sb.append("value: %s"%value)
	sb.append("start: %s"%start_position)
	sb.append("end: %s"%end_position)
	sb.append("kind: %s"%kind)
	return " | ".join(sb)
