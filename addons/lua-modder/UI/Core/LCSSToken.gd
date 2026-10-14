
class_name LCSSToken
extends RefCounted


enum Type {
	IDENTIFIER,
	AT_KEYWORD,
	NUMBER,
	DIMENSION,
	PERCENTAGE,
	COLOR,
	HASH,
	STRING,
	COMMENT,
	LBRACE,
	RBRACE,
	COLON,
	SEMICOLON,
	COMMA,
	DOT,
	LPAREN,
	RPAREN,
	LBRACKET,
	RBRACKET,
	PLUS,
	MINUS,
	UNKNOWN,
	EOF,
}


var type: int
var lexeme: String

var start_offset: int
var end_offset: int

var line: int
var column: int
var end_line: int
var end_column: int

var is_terminated: bool = true


func _init(
	p_type: int,
	p_lexeme: String,
	p_start_offset: int,
	p_end_offset: int,
	p_line: int,
	p_column: int,
	p_end_line: int,
	p_end_column: int,
	p_is_terminated: bool = true
) -> void:
	type = p_type
	lexeme = p_lexeme

	start_offset = p_start_offset
	end_offset = p_end_offset

	line = p_line
	column = p_column
	end_line = p_end_line
	end_column = p_end_column

	is_terminated = p_is_terminated


func get_length() -> int:
	return end_offset - start_offset


func is_type(expected_type: int) -> bool:
	return type == expected_type
