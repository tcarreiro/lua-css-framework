class_name LCSSStyleClass extends RefCounted

var style_sheet: LCSSStyleSheet
var token: LCSSToken
var name: StringName
var states: Dictionary[StringName, LCSSState] = {}
var properties: Dictionary[StringName, LCSSProperty] = {}

func _init(_style_sheet: LCSSStyleSheet, _token: LCSSToken) -> void:
	style_sheet = _style_sheet
	token = _token
	parse()


func parse() -> void:
	LCSSParser.parse_style_class(self)


func set_name(new_name: StringName)-> void:
	name = new_name


func add_state(_state: LCSSState) -> void:
	states[_state.name] = _state


func add_property(_property: LCSSProperty) -> void:
	properties[_property.name] = _property


func _to_string() -> String:
	return "LCSSStyleClass(name=%s, states=%s, properties=%s)" % [
		name, states.values(), properties.values()
	]
