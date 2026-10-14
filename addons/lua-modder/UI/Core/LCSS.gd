
@tool
class_name LCSS extends RefCounted


# -------------------------------------------------------------------
# Property types
# -------------------------------------------------------------------
enum Type {
	INT,
	FLOAT,
	BOOLEAN,
	COLOR,
	COMPOSITE,
	COMPOSITE4,
	CURSOR,
	TRANSITION_TYPE,
	TRANSITION_FUNC,
	ICON,
	FONT,
	VECTOR2,
	AUDIO,
}


# -------------------------------------------------------------------
# Property values
# -------------------------------------------------------------------
enum CursorType {
	ARROW,
	IBEAM,
	POINTING,
	CROSS,
	WAIT,
	BUSY,
	DRAG,
	CAN_DROP,
	FORBIDDEN,
	DISABLED = FORBIDDEN,
	VSIZE,
	HSIZE,
	BDIAGSIZE,
	FDIAGSIZE,
	MOVE,
	VSPLIT,
	HSPLIT,
	HELP,
}


enum TransitionType {
	EASE_IN,
	EASE_OUT,
	EASE_IN_OUT,
	EASE_OUT_IN,
}


enum TransitionFunc {
	LINEAR,
	SINE,
	QUINT,
	QUART,
	QUAD,
	EXPO,
	ELASTIC,
	CUBIC,
	CIRC,
	BOUNCE,
	BACK,
	SPRING,
}


# -------------------------------------------------------------------
# Lexical markers
# -------------------------------------------------------------------
const LINE_COMMENT_START := "//"
const BLOCK_COMMENT_START := "/*"
const BLOCK_COMMENT_END := "*/"

const STYLE_MARKER := "."
const STATE_MARKER := ":"
const AT_MARKER := "@"
const COLOR_MARKER := "#"

const KEYFRAMES_DIRECTIVE := "@keyframes"
const KEYFRAME_FROM := "from"
const KEYFRAME_TO := "to"

const BLOCK_OPEN := "{"
const BLOCK_CLOSE := "}"

const DECLARATION_SEPARATOR := ":"
const DECLARATION_END := ";"
const SELECTOR_SEPARATOR := ","

const FUNCTION_OPEN := "("
const FUNCTION_CLOSE := ")"

const ARRAY_OPEN := "["
const ARRAY_CLOSE := "]"

const STRING_DOUBLE_QUOTE := "\""
const STRING_SINGLE_QUOTE := "'"

const SIGN_PLUS := "+"
const SIGN_MINUS := "-"


# -------------------------------------------------------------------
# Unit
# -------------------------------------------------------------------
const DIMENSION_UNITS: Array[String] = [
	"ms",
	"s",
]
