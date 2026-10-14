@tool
class_name LCSSSyntaxNode extends RefCounted


var start_offset: int = 0
var end_offset: int = 0

var line: int = 1
var column: int = 1

var end_line: int = 1
var end_column: int = 1


func set_start(token: LCSSToken) -> void:
	start_offset = token.start_offset
	line = token.line
	column = token.column


func set_end(token: LCSSToken) -> void:
	end_offset = token.end_offset
	end_line = token.end_line
	end_column = token.end_column
