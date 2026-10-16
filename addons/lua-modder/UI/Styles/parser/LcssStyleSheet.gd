class_name LCSSStyleSheet extends RefCounted

var rules: Array[LCSSRule] = []
var _keyframes: Dictionary = {}   # nome -> LCSSKeyframes

var style_classes: Dictionary[StringName, LCSSStyleClass] = {}
var keyframes: Dictionary[StringName, LCSSKeyframes] = {}
var comments: Array[LCSSToken] = []
var parts: Array[String] = []


func add_style_class(style_class: LCSSStyleClass) -> void:
	style_classes[style_class.name] = style_class


func add_rule(rule: LCSSRule) -> void:
	rules.append(rule)


func get_rules() -> Array[LCSSRule]:
	return rules.duplicate()


func add_keyframes(anim_name: String, frames: LCSSKeyframes) -> void:
	keyframes[anim_name] = frames


#
#func parse(selector: String) -> void:
	#parts.clear()
#
	#for raw_part in selector.strip_edges().split(" ", false):
		#parts.append(_parse_part(raw_part))
#
#
#func matches(component: LuaComponent, match_states: bool = true) -> bool:
	#if component == null or parts.is_empty():
		#return false
#
	#var part_index := parts.size() - 1
	#var current: LuaComponent = component
#
	#if not _matches_part(parts[part_index], current, match_states):
		#return false
#
	#part_index -= 1
#
	#while part_index >= 0:
		#current = _find_matching_ancestor(parts[part_index], current, match_states)
#
		#if current == null:
			#return false
#
		#part_index -= 1
#
	#return true
#
#
#func _find_matching_ancestor(part: Dictionary, from_component: LuaComponent,
		#match_states: bool) -> LuaComponent:
	#var node := from_component.get_parent()
#
	#while node != null:
		#if node is LuaComponent:
			#var component := node as LuaComponent
#
			#if _matches_part(part, component, match_states):
				#return component
#
		#node = node.get_parent()
#
	#return null
#
#
#func _matches_part(part: Dictionary, component: LuaComponent,
		#match_states: bool) -> bool:
	#for style_class: StringName in part["classes"]:
		#if not component.has_class(style_class):
			#return false
#
	#if match_states:
		#for state: StringName in part["states"]:
			#if not component.is_style_state_active(state):
				#return false
#
	#return true
#
#
#func _parse_part(raw_part: String) -> Dictionary:
	#var part: Dictionary = {
		#"classes": [],
		#"states": [],
	#}
#
	#var remaining := raw_part
#
	#while not remaining.is_empty():
		#if remaining.begins_with("."):
			#var end := _find_token_end(remaining, 1)
			#var style_class := remaining.substr(1, end - 1)
#
			#if not style_class.is_empty():
				#part["classes"].append(StringName(style_class))
#
			#remaining = remaining.substr(end)
			#continue
#
		#if remaining.begins_with(":"):
			#var end := _find_token_end(remaining, 1)
			#var state := remaining.substr(1, end - 1)
#
			#if not state.is_empty():
				#part["states"].append(StringName(state))
#
			#remaining = remaining.substr(end)
			#continue
#
		#push_warning(
			#"[LCSSSelector] token desconhecido em selector '%s': '%s'"
			#% [raw_part, remaining]
		#)
		#break
#
	#return part
#
#
#func _find_token_end(value: String, start: int) -> int:
	#var index := start
#
	#while index < value.length():
		#var character := value[index]
#
		#if character == "." or character == ":":
			#break
#
		#index += 1
#
	#return index
#
#
##func get_specificity() -> int:
	##var specificity := 0
##
	##for part in parts:
		##specificity += part["classes"].size()
		##specificity += part["states"].size()
##
	##return specificity
