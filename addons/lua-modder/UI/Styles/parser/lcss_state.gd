class_name LCSSState extends RefCounted

var name: StringName

func _init(_name:StringName) -> void:
	name = _name


func _to_string() -> String:
	return "LCSSState(name=%s)" % name
