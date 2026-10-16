class_name LCSSStyleClass extends RefCounted

var token: LCSSToken
var name: StringName
var states: Dictionary[StringName, LCSSState] = {}
var properties: Dictionary[StringName, LCSSProperty] = {}

func _init(_token: LCSSToken) -> void:
	token = _token
	parse()


func parse() -> void:
	LCSSParser.parse_style_class(self)


func add_property(_property: LCSSProperty) -> void:
	properties[_property.name] = _property
