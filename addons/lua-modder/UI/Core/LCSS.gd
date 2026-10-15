@tool
class_name LCSS extends RefCounted

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

# -------------------------------------------------------------------
# Syntax highlighting and completion
# -------------------------------------------------------------------
const PSEUDO_STATES: Array[String] = [
	"hover",
	"pressed",
	"focus",
	"disabled",
]

const KEYWORDS: Array[String] = [
	"true",
	"false",
	"null",
]


# -------------------------------------------------------------------
# Property metadata
# -------------------------------------------------------------------
const ANY := TYPE_NIL 
const TYPE := "type"
const DOC := "doc"
const DEFAULT := "default"
const OPTIONS := "options"

#region Functions
const TEXTURE_FN = &"texture"
const URL_FN = &"url"
#endregion

#region Names
const ID := &"id"
const CLASS := &"class"
const VISIBLE := &"visible"
const TOOLTIP := &"tooltip"

const MIN := &"min"
const MAX := &"max"
const STEP := &"step"
const SHOW_VALUE := &"show_value"
const TRACK_HEIGHT := &"track_height"
const THUMB_SIZE := &"thumb_size"

const DRAGGABLE := &"draggable"
const DRAG_MODE := &"drag_mode"
const DRAG_HANDLE := &"drag_handle"
const DRAG_BOUNDS := &"drag_bounds"
const DRAG_CURSOR := &"drag_cursor"

const MODEL := &"model"
const CHECKED := &"checked"
const RADIO := &"radio"
const INDICATOR_SIZE := &"indicator_size"
const MARK_INSET := &"mark_inset"
const OPTION_LIST := &"options" 
const OPTION_CLASS := &"option_class"
const LIST_CLASS := &"list_class"
const LIST_MAX_HEIGHT := &"list_max_height"
const PLACEHOLDER := &"placeholder"
const CARET := &"caret"
const JUSTIFY_SELF := &"justify_self"
const POINTER_EVENTS := &"pointer_events"

const MARGIN := &"margin"
const MARGIN_LEFT := &"margin_left"
const MARGIN_TOP := &"margin_top"
const MARGIN_RIGHT := &"margin_right"
const MARGIN_BOTTOM := &"margin_bottom"
const PADDING := &"padding"
const PADDING_LEFT := &"padding_left"
const PADDING_TOP := &"padding_top"
const PADDING_RIGHT := &"padding_right"
const PADDING_BOTTOM := &"padding_bottom"

const DISPLAY := &"display"
const ALIGN_ITEMS := &"align_items"
const ALIGN_SELF := &"align_self"

const BACKGROUND_COLOR := &"background_color"
const BORDER_COLOR := &"border_color"
const BORDER_WIDTH := &"border_width"
const BORDER_WIDTH_LEFT := &"border_width_left"
const BORDER_WIDTH_TOP := &"border_width_top"
const BORDER_WIDTH_RIGHT := &"border_width_right"
const BORDER_WIDTH_BOTTOM := &"border_width_bottom"
const BORDER_RADIUS := &"border_radius"
const BORDER_RADIUS_TOP_LEFT := &"border_radius_top_left"
const BORDER_RADIUS_TOP_RIGHT := &"border_radius_top_right"
const BORDER_RADIUS_BOTTOM_RIGHT := &"border_radius_bottom_right"
const BORDER_RADIUS_BOTTOM_LEFT := &"border_radius_bottom_left"

const DROP_SHADOW_COLOR := &"drop_shadow_color"
const DROP_SHADOW_SIZE := &"drop_shadow_size"
const DROP_SHADOW_OFFSET := &"drop_shadow_offset"

const GAP := &"gap"
const WIDTH := &"width"
const HEIGHT := &"height"
const MAX_WIDTH := &"max_width"
const MAX_HEIGHT := &"max_height"
const COLUMNS := &"columns"
const COLUMN_GAP := &"column_gap"
const ROW_GAP := &"row_gap"
const FILL_CELLS := &"fill_cells" 

const DIRECTION := &"direction"
const ALIGNMENT := &"alignment"

const FOLLOW_FOCUS := &"follow_focus"
const EDGE_THRESHOLD := &"edge_threshold"
const SCROLLBAR_MODE := &"scrollbar_mode"
const SCROLLBAR_GAP := &"scrollbar_gap"
const SCROLLBAR_WIDTH := &"scrollbar_width"
const SCROLLBAR_BORDER_RADIUS := &"scrollbar_border_radius"
const SCROLLBAR_BORDER_RADIUS_TOP_LEFT := &"scrollbar_border_radius_top_left"
const SCROLLBAR_BORDER_RADIUS_TOP_RIGHT := &"scrollbar_border_radius_top_right"
const SCROLLBAR_BORDER_RADIUS_BOTTOM_RIGHT := &"scrollbar_border_radius_bottom_right"
const SCROLLBAR_BORDER_RADIUS_BOTTOM_LEFT := &"scrollbar_border_radius_bottom_left"
const SCROLLBAR_TRACK_COLOR := &"scrollbar_track_color"
const SCROLLBAR_GRABBER_COLOR := &"scrollbar_grabber_color"
const SCROLLBAR_GRABBER_HOVER_COLOR := &"scrollbar_grabber_hover_color"
const SCROLLBAR_GRABBER_PRESSED_COLOR := &"scrollbar_grabber_pressed_color"
const SCROLL_HINT := &"scroll_hint"
const SCROLL_HINT_TILE := &"scroll_hint_tile"
const SCROLL_HINT_COLOR := &"scroll_hint_color"

const BBCODE_ENABLED := &"bbcode_enabled"
const AUTOWRAP := &"autowrap"
const FIT_CONTENT := &"fit_content"
const SCROLL_ACTIVE := &"scroll_active"
const SCROLL_FOLLOWING := &"scroll_following"
const SELECTION_ENABLED := &"selection_enabled"
const FONT_SHADOW_COLOR := &"font_shadow_color"
const TEXT_ALIGN := &"text_align"
const TEXT_VALIGN := &"text_valign"
const UPPERCASE := &"uppercase"
const TEXT_OVERFLOW := &"text_overflow"
const CLIP_TEXT := &"clip_text"
const MAX_LINES := &"max_lines"
const LINES_SKIPPED := &"lines_skipped"
const VISIBLE_CHARACTERS := &"visible_characters"
const VISIBLE_RATIO := &"visible_ratio"
const AUTO_FONT_SIZE := &"auto_font_size"
const MIN_FONT_SIZE := &"min_font_size"
const MAX_FONT_SIZE := &"max_font_size"
const LINE_SPACING := &"line_spacing"
const PARAGRAPH_SPACING := &"paragraph_spacing"
const TEXT_SHADOW_COLOR := &"text_shadow_color"
const TEXT_SHADOW_OFFSET := &"text_shadow_offset"
const TEXT_SHADOW_OUTLINE := &"text_shadow_outline"
const META_UNDERLINED := &"meta_underlined"
const HINT_UNDERLINED := &"hint_underlined"
const SELECTION_COLOR := &"selection_color"
const SELECTED_FONT_COLOR := &"selected_font_color"
const TAB_SIZE := &"tab_size"
const SCROLL_FOLLOWING_VISIBLE := &"scroll_following_visible_characters"

const FONT_COLOR := &"font_color"
const FONT_SIZE := &"font_size"
const OUTLINE_COLOR := &"outline_color"
const OUTLINE_THICKNESS := &"outline_thickness"

const DISABLED := &"disabled"
const BLOCKING := &"blocking"
const BACKDROP_COLOR := &"backdrop_color"
const TEXT := &"text"
const LABEL := &"label"
const VALUE := &"value"
const INPUT_TYPE := &"type"   # não usar TYPE: já é a chave "type" dos dicts de definição
const DECIMALS := &"decimals"
const THOUSAND_SEPARATOR := &"thousand_separator"
const DECIMAL_SEPARATOR := &"decimal_separator"
const ICON := &"icon"
const ICON_SIDE := &"icon_side"
const CURSOR := &"cursor"

const BACKGROUND_IMAGE := &"background_image"
const BACKGROUND_IMAGE_TINT := &"background_image_tint"
const BACKGROUND_IMAGE_STRETCH := &"background_image_stretch"
const BACKGROUND_IMAGE_SLICE := &"background_image_slice"
const BACKGROUND_IMAGE_SLICE_LEFT := &"background_image_slice_left"
const BACKGROUND_IMAGE_SLICE_TOP := &"background_image_slice_top"
const BACKGROUND_IMAGE_SLICE_RIGHT := &"background_image_slice_right"
const BACKGROUND_IMAGE_SLICE_BOTTOM := &"background_image_slice_bottom"

const TRANSITION_DURATION := &"transition_duration"
const TRANSITION_EASING := &"transition_easing"
const TRANSITION_LOOP := &"transition_loop"
const TRANSITION_REPETITIONS := &"transition_repetitions"
const TRANSITION_PROPERTIES := &"transition_properties"

const TEXTURE := &"texture"
const HFRAMES := &"hframes"
const VFRAMES := &"vframes"
const FRAME_COUNT := &"frame_count"
const FRAME := &"frame"
const FPS := &"fps"
const DURATION := &"duration"
const LOOP := &"loop"
const PLAYING := &"playing"

const SCALE := &"scale"
const ROTATE := &"rotate"
const TRANSLATE := &"translate"
const TRANSFORM_ORIGIN := &"transform_origin"

const ANIMATION_NAME := &"animation_name"
const ANIMATION_DURATION := &"animation_duration"
const ANIMATION_EASING := &"animation_easing"
const ANIMATION_ITERATIONS := &"animation_iterations"
const ANIMATION_DIRECTION := &"animation_direction"
const ANIMATION_DELAY := &"animation_delay"
const ANIMATION_FILL := &"animation_fill"

const EFFECTS := &"effects"
const EFFECT := &"effect"
const PARAMS := &"params"
const ACTIVE := &"active"
const EMITTING := &"emitting"
const AMOUNT := &"amount"
const LIFETIME := &"lifetime"
const EXPLOSIVENESS := &"explosiveness"
const RANDOMNESS := &"randomness"
const PREWARM := &"prewarm"
const SHAPE := &"shape"
const EMIT_ANGLE := &"emit_angle"
const SPREAD := &"spread"
const SPEED := &"speed"
const GRAVITY := &"gravity"
const PARTICLE_SCALE := &"particle_scale"
const COLOR := &"color"
const COLOR_END := &"color_end"
const BLEND := &"blend"
#endregion

#region Values
const HOLD := &"hold"
const TOGGLE := &"toggle"
const VIEWPORT := &"viewport"

const VERTICAL := &"vertical"
const HORIZONTAL := &"horizontal"
const BOTH := &"both"
const AUTO := &"auto"
const ALWAYS := &"always"
const NEVER := &"never"
const RESERVE := &"reserve"
const GROW := &"grow"
const NONE := &"none"
const ALL := &"all"
const START := &"start"
const END := &"end"
const BLOCK := &"block"
const FLEX := &"flex"
const FLEX_GROW := &"flex_grow"
const NUMBER := &"number"
const SECRET := &"secret"
const LEFT := &"left"
const RIGHT := &"right"
const CENTER := &"center"
const FILL := &"fill"
const TOP := &"top"
const MIDDLE := &"middle"
const BOTTOM := &"bottom"
const CLIP := &"clip"
const ELLIPSIS := &"ellipsis"
const WORD_ELLIPSIS := &"word_ellipsis"
const TRIM := &"trim"

const POINTER := &"pointer"
const CROSSHAIR := &"crosshair"
const WAIT := &"wait"
const BUSY := &"busy"
const MOVE := &"move"
const NOT_ALLOWED := &"not_allowed"
const HELP := &"help"
const DRAG := &"drag"
const CAN_DROP := &"can_drop"

const NORMAL := &"normal"
const ALTERNATE := &"alternate"
const FORWARDS := &"forwards"
const INFINITE := &"infinite"

const STRETCH := &"stretch"
const TILE := &"tile"
const TILE_FIT := &"tile_fit"
const LINEAR := &"linear"
const EASE_IN := &"ease_in"
const EASE_OUT := &"ease_out"
const EASE_IN_OUT := &"ease_in_out"
const BACK := &"back"
const ELASTIC := &"elastic"
const BOUNCE := &"bounce"

const ONE_SHOT := &"one_shot"
const PING_PONG := &"ping_pong"
const POINT := &"point"
const BOX := &"box"
const SPHERE := &"sphere"
const MIX := &"mix"
const ADD := &"add"
const SUBTRACT := &"subtract"
const MULTIPLY := &"multiply"
const PREMULTIPLIED_ALPHA := &"premultiplied_alpha"

const OFF := &"off"
const WORD := &"word"
const WORD_SMART := &"word_smart"
const CHAR := &"char"
#endregion

const BASE: Array[String] = [
	ID,
	CLASS,
	VISIBLE,
	TOOLTIP,
	DISABLED,
	FLEX_GROW,
	ALIGN_SELF,
	JUSTIFY_SELF,
	POINTER_EVENTS,
	EFFECTS,
]


#region Groups
const BOX_SPACING: Array[StringName] = [
	MARGIN, PADDING
]

const DRAG_GRP: Array[StringName] = [DRAGGABLE, DRAG_MODE, DRAG_HANDLE, DRAG_BOUNDS, DRAG_CURSOR]

const PANEL: Array[StringName] = [
	BACKGROUND_COLOR, BORDER_COLOR, BORDER_WIDTH, BORDER_RADIUS,
	DROP_SHADOW_COLOR, DROP_SHADOW_SIZE, DROP_SHADOW_OFFSET,
	BACKGROUND_IMAGE, BACKGROUND_IMAGE_TINT, BACKGROUND_IMAGE_STRETCH,
	BACKGROUND_IMAGE_SLICE,
]

const TRANSITION: Array[StringName] = [
	TRANSITION_DURATION, TRANSITION_EASING, TRANSITION_PROPERTIES,
	TRANSITION_LOOP, TRANSITION_REPETITIONS,
]

const TRANSFORM: Array[StringName] = [SCALE, ROTATE, TRANSLATE, TRANSFORM_ORIGIN]


const SCROLLBAR: Array[StringName] = [
	SCROLLBAR_WIDTH, SCROLLBAR_GAP, SCROLLBAR_BORDER_RADIUS, SCROLLBAR_TRACK_COLOR,
	SCROLLBAR_GRABBER_COLOR, SCROLLBAR_GRABBER_HOVER_COLOR,
	SCROLLBAR_GRABBER_PRESSED_COLOR, SCROLL_HINT_COLOR,
]

const FONT: Array[StringName] = [
	FONT_COLOR, FONT_SIZE, OUTLINE_COLOR, OUTLINE_THICKNESS,
]

const TEXT_SHADOW: Array[StringName] = [TEXT_SHADOW_COLOR, TEXT_SHADOW_OFFSET, TEXT_SHADOW_OUTLINE]
const TEXT_LAYOUT: Array[StringName] = [
	TEXT_ALIGN, TEXT_VALIGN, AUTOWRAP, LINE_SPACING, PARAGRAPH_SPACING,
	AUTO_FONT_SIZE, MIN_FONT_SIZE, MAX_FONT_SIZE, VISIBLE_CHARACTERS, VISIBLE_RATIO,
]
const LABEL_ONLY: Array[StringName] = [UPPERCASE, TEXT_OVERFLOW, CLIP_TEXT, MAX_LINES, LINES_SKIPPED]
const RICH_ONLY: Array[StringName] = [
	BBCODE_ENABLED, FIT_CONTENT, SCROLL_ACTIVE, SCROLL_FOLLOWING, SCROLL_FOLLOWING_VISIBLE,
	SELECTION_ENABLED, META_UNDERLINED, HINT_UNDERLINED, SELECTION_COLOR, SELECTED_FONT_COLOR, TAB_SIZE,
]

const ANIMATION: Array[StringName] = [
	ANIMATION_NAME, ANIMATION_DURATION, ANIMATION_EASING, ANIMATION_ITERATIONS,
	ANIMATION_DIRECTION, ANIMATION_DELAY, ANIMATION_FILL,
]
const ANIMATION_DIRECTIONS := [NORMAL, ALTERNATE]
const ANIMATION_FILLS := [NONE, FORWARDS]

#endregion

#region Families
const FAMILIES := {
	MARGIN: [
		MARGIN_LEFT, MARGIN_TOP, MARGIN_RIGHT, MARGIN_BOTTOM
	],
	PADDING: [
		PADDING_LEFT, PADDING_TOP, PADDING_RIGHT, PADDING_BOTTOM
	],
	BORDER_WIDTH: [
		BORDER_WIDTH_LEFT, BORDER_WIDTH_TOP, BORDER_WIDTH_RIGHT, BORDER_WIDTH_BOTTOM
	],
	BORDER_RADIUS: [
		BORDER_RADIUS_TOP_LEFT, BORDER_RADIUS_TOP_RIGHT,
		BORDER_RADIUS_BOTTOM_RIGHT, BORDER_RADIUS_BOTTOM_LEFT
	],
	SCROLLBAR_BORDER_RADIUS: [
		SCROLLBAR_BORDER_RADIUS_TOP_LEFT, SCROLLBAR_BORDER_RADIUS_TOP_RIGHT,
		SCROLLBAR_BORDER_RADIUS_BOTTOM_RIGHT, SCROLLBAR_BORDER_RADIUS_BOTTOM_LEFT
	],
	BACKGROUND_IMAGE_SLICE: [
		BACKGROUND_IMAGE_SLICE_LEFT, BACKGROUND_IMAGE_SLICE_TOP,
		BACKGROUND_IMAGE_SLICE_RIGHT, BACKGROUND_IMAGE_SLICE_BOTTOM
	],
}


static var _family_index: Dictionary = {}

static func members_of(family: StringName) -> Array:
	return FAMILIES.get(family, [])


static func family_of(name: StringName) -> StringName:
	if _family_index.is_empty():
		for family: StringName in FAMILIES:
			_family_index[family] = family
			for member: StringName in FAMILIES[family]:
				_family_index[member] = family
	return _family_index.get(name, &"")


static func expand(names: Array) -> Array:
	var out: Array = []
	for n in names:
		var sn := StringName(n)
		out.append(sn)
		if FAMILIES.has(sn):
			out.append_array(FAMILIES[sn])
	return out


static func _defined(v: Variant) -> bool:
	if v == null:
		return false
	if (v is Array or v is Dictionary) and v.is_empty():
		return false
	return true


## Um valor por parte (null = ninguém definiu).
## `layers`: lookups da MAIOR para a MENOR prioridade; cada um recebe o nome da prop
## e devolve o valor ou null. Dentro de cada camada, a parte vence o atalho.
static func resolve_family(family: StringName, layers: Array[Callable]) -> Array:
	var members: Array = members_of(family)
	var out: Array = []
	out.resize(members.size())
	for layer: Callable in layers:
		var shorthand: Variant = layer.call(family)
		var distributed: Array = LuaHelper.parse_distributable(shorthand) if _defined(shorthand) else []
		for i in members.size():
			if out[i] != null:
				continue
			var specific: Variant = layer.call(members[i])
			if _defined(specific):
				out[i] = LuaHelper.parse_distributable(specific)[0]
			elif not distributed.is_empty():
				out[i] = distributed[i]
	return out
#endregion

#region Options
const DIRECTIONS := [
	VERTICAL, HORIZONTAL, BOTH
]

const ALIGNMENTS := {
	CENTER: BoxContainer.AlignmentMode.ALIGNMENT_CENTER,
	START: BoxContainer.AlignmentMode.ALIGNMENT_BEGIN, 
	END: BoxContainer.AlignmentMode.ALIGNMENT_END,
}

const CROSS_ALIGNS := {
	STRETCH: Control.SIZE_FILL,
	START: Control.SIZE_SHRINK_BEGIN,
	CENTER: Control.SIZE_SHRINK_CENTER,
	END: Control.SIZE_SHRINK_END,
}

const DRAG_MODES := [HOLD, TOGGLE]

const DRAG_BOUNDS_OPTIONS := [VIEWPORT, NONE]

const DISPLAYS := [
	BLOCK, FLEX,
]

const SCROLL_MODES := {
	AUTO: ScrollContainer.SCROLL_MODE_AUTO,
	ALWAYS: ScrollContainer.SCROLL_MODE_SHOW_ALWAYS,
	NEVER: ScrollContainer.SCROLL_MODE_SHOW_NEVER,
	RESERVE: ScrollContainer.SCROLL_MODE_RESERVE,
	GROW: ScrollContainer.SCROLL_MODE_MAXIMIZE_FIRST,
}

const HINT_MODES := {
	NONE: ScrollContainer.SCROLL_HINT_MODE_DISABLED,
	ALL: ScrollContainer.SCROLL_HINT_MODE_ALL,
	START: ScrollContainer.SCROLL_HINT_MODE_TOP_AND_LEFT,
	END: ScrollContainer.SCROLL_HINT_MODE_BOTTOM_AND_RIGHT,
}

const INPUT_TYPES := [TEXT, NUMBER, SECRET]
const ICON_SIDES := [LEFT, RIGHT]

const CURSORS := {
	DEFAULT: Control.CURSOR_ARROW,
	TEXT: Control.CURSOR_IBEAM,
	POINTER: Control.CURSOR_POINTING_HAND,
	CROSSHAIR: Control.CURSOR_CROSS,
	WAIT: Control.CURSOR_WAIT,
	BUSY: Control.CURSOR_BUSY,
	MOVE: Control.CURSOR_MOVE,
	NOT_ALLOWED: Control.CURSOR_FORBIDDEN,
	HELP: Control.CURSOR_HELP,
	DRAG: Control.CURSOR_DRAG,
	CAN_DROP: Control.CURSOR_CAN_DROP,
}

const STRETCH_MODES := {
	STRETCH: StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH,
	TILE: StyleBoxTexture.AXIS_STRETCH_MODE_TILE,
	TILE_FIT: StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT,
}

const EASINGS := {
	LINEAR: [Tween.TRANS_LINEAR, Tween.EASE_IN_OUT],
	EASE_IN: [Tween.TRANS_QUAD, Tween.EASE_IN],
	EASE_OUT: [Tween.TRANS_QUAD, Tween.EASE_OUT],
	EASE_IN_OUT: [Tween.TRANS_QUAD, Tween.EASE_IN_OUT],
	BACK: [Tween.TRANS_BACK, Tween.EASE_OUT],
	ELASTIC: [Tween.TRANS_ELASTIC, Tween.EASE_OUT],
	BOUNCE: [Tween.TRANS_BOUNCE, Tween.EASE_OUT],
}

const LOOP_OPTIONS := [
	LOOP, PING_PONG, ONE_SHOT,
]

const AUTOWRAP_MODES := {
	OFF: TextServer.AUTOWRAP_OFF,
	WORD: TextServer.AUTOWRAP_WORD,
	WORD_SMART: TextServer.AUTOWRAP_WORD_SMART,
	CHAR: TextServer.AUTOWRAP_ARBITRARY,
}


const H_ALIGNS := {
	LEFT: HORIZONTAL_ALIGNMENT_LEFT, CENTER: HORIZONTAL_ALIGNMENT_CENTER,
	RIGHT: HORIZONTAL_ALIGNMENT_RIGHT, FILL: HORIZONTAL_ALIGNMENT_FILL,
}


const V_ALIGNS := {
	TOP: VERTICAL_ALIGNMENT_TOP, MIDDLE: VERTICAL_ALIGNMENT_CENTER,
	BOTTOM: VERTICAL_ALIGNMENT_BOTTOM, FILL: VERTICAL_ALIGNMENT_FILL,
}


const TEXT_OVERFLOWS := {
	NONE: TextServer.OVERRUN_NO_TRIMMING, CLIP: TextServer.OVERRUN_TRIM_CHAR,
	WORD: TextServer.OVERRUN_TRIM_WORD, ELLIPSIS: TextServer.OVERRUN_TRIM_ELLIPSIS,
	WORD_ELLIPSIS: TextServer.OVERRUN_TRIM_WORD_ELLIPSIS,
}

const EMIT_SHAPES := {
	POINT: CPUParticles2D.EMISSION_SHAPE_POINT,
	BOX: CPUParticles2D.EMISSION_SHAPE_RECTANGLE,
	SPHERE: CPUParticles2D.EMISSION_SHAPE_SPHERE,
}
const BLENDS := [MIX, ADD, SUBTRACT, MULTIPLY, PREMULTIPLIED_ALPHA]
#endregion

static var _cache: Dictionary = {}


static func type_of(name: StringName) -> int:
	return _catalog().get(String(name), {}).get(TYPE, TYPE_NIL)


## Ex.: pick([GAP, DIRECTION], {GAP: 4})
static func pick(names: Array, defaults: Dictionary = {}, prefix: String = "") -> Dictionary:
	var all := _catalog()
	var overrides := {}
	for d in defaults:
		overrides[String(d)] = defaults[d]

	var out := {}
	for n in expand(names):
		var key := String(n)
		if not all.has(key):
			push_warning("[LCSS] prop desconhecida: '%s'" % key)
			continue
		var def: Dictionary = all[key].duplicate(true)
		if overrides.has(key):
			def[DEFAULT] = overrides[key]
		out[prefix + key] = def

	for key in overrides:
		if not out.has(prefix + key):
			push_warning("[LCSS] default para prop que não está no pick: '%s'" % key)
	return out


static func _add(c: Dictionary, name: StringName, type: int, default: Variant,
		doc: String = "", options: Array = []) -> void:
	var def := {TYPE: type, DEFAULT: default, DOC: doc}
	if not options.is_empty():
		def[OPTIONS] = options
	c[String(name)] = def


static func _catalog() -> Dictionary:
	if not _cache.is_empty():
		return _cache
	var c := _cache
#region Catalog
	_add(c, ID, TYPE_STRING, "", "Component identifier.")
	_add(c, CLASS, TYPE_STRING, "", "List of style classes.")
	_add(c, VISIBLE, TYPE_BOOL, true, "Component visibility.")
	_add(c, TOOLTIP, TYPE_STRING, "", "Tooltip displayed for the component.") # To be implemented
	_add(c, FLEX_GROW, TYPE_FLOAT, 0.0, "Share of the container's available space allocated to this component. 0 = content size only; other values distribute space proportionally.")

	_add(c, MIN, TYPE_FLOAT, 0.0, "Minimum value.")
	_add(c, MAX, TYPE_FLOAT, 100.0, "Maximum value.")
	_add(c, STEP, TYPE_FLOAT, 1.0, "Value increment (0 = continuous).")
	_add(c, SHOW_VALUE, TYPE_BOOL, false, "Displays the current value beside the slider.")
	_add(c, TRACK_HEIGHT, TYPE_INT, 6, "Track thickness in pixels.")
	_add(c, THUMB_SIZE, ANY, 20, "Thumb size in pixels: a number or {width, height}.")

	_add(c, DRAGGABLE, TYPE_BOOL, false, "Allows the component to be dragged with the mouse.")
	_add(c, DRAG_MODE, TYPE_STRING, "hold", "hold: drag while the button is held. toggle: click to pick up and click again to release.", DRAG_MODES)
	_add(c, DRAG_HANDLE, TYPE_BOOL, false, "Designates this component as a drag handle for an ancestor with draggable enabled. If no handle exists, the entire ancestor acts as the handle.")
	_add(c, DRAG_BOUNDS, TYPE_STRING, "viewport", "viewport keeps the cursor within the screen during dragging; none disables the limit.", DRAG_BOUNDS_OPTIONS)
	_add(c, DRAG_CURSOR, TYPE_STRING, "move", "Cursor displayed over the drag region while draggable is enabled.", CURSORS.keys())

	_add(c, MARGIN, ANY, null, "Outer margin: a number, {horizontal, vertical}, or {left, top, right, bottom}.")
	_add(c, MARGIN_LEFT, ANY, null, "Left outer margin.")
	_add(c, MARGIN_TOP, ANY, null, "Top outer margin.")
	_add(c, MARGIN_RIGHT, ANY, null, "Right outer margin.")
	_add(c, MARGIN_BOTTOM, ANY, null, "Bottom outer margin.")
	_add(c, PADDING, ANY, null, "Inner spacing: a number, {horizontal, vertical}, or {left, top, right, bottom}.")
	_add(c, PADDING_LEFT, ANY, null, "Left inner spacing.")
	_add(c, PADDING_TOP, ANY, null, "Top inner spacing.")
	_add(c, PADDING_RIGHT, ANY, null, "Right inner spacing.")
	_add(c, PADDING_BOTTOM, ANY, null, "Bottom inner spacing.")

	_add(c, DISPLAY, TYPE_STRING, "block", "Container layout. {block} stacks children vertically; {flex} stacks them horizontally.", DISPLAYS)
	_add(c, DISABLED, TYPE_BOOL, false, "Disables interaction and activates the :disabled state.")
	_add(c, BLOCKING, TYPE_BOOL, true, "When true, the backdrop blocks clicks on elements behind it.")
	_add(c, BACKDROP_COLOR, TYPE_COLOR, null, "Background color behind the modal.")
	_add(c, TEXT, TYPE_STRING, "", "Displayed text.")
	_add(c, LABEL, TYPE_STRING, "", "Button text or field label.")
	_add(c, VALUE, TYPE_STRING, "", "Current field value.")
	_add(c, INPUT_TYPE, TYPE_STRING, "text", "Input type.", INPUT_TYPES)
	_add(c, DECIMALS, TYPE_INT, 0, "Number of decimal places (for type number only).")
	_add(c, THOUSAND_SEPARATOR, TYPE_STRING, ".", "Thousands separator (for type number only).")
	_add(c, DECIMAL_SEPARATOR, TYPE_STRING, ",", "Decimal separator (for type number only).")
	_add(c, ICON, TYPE_STRING, "", "Path to the icon texture.")
	_add(c, ICON_SIDE, TYPE_STRING, "left", "Icon placement.", ICON_SIDES)
	_add(c, CURSOR, TYPE_STRING, "default", "Mouse cursor displayed over the component.", CURSORS.keys())

	_add(c, BACKGROUND_COLOR, TYPE_COLOR, null, "Background color.")
	_add(c, BORDER_COLOR, TYPE_COLOR, null, "Border color.")
	_add(c, BORDER_WIDTH, ANY, null, "Border thickness in pixels.")
	_add(c, BORDER_WIDTH_LEFT, ANY, null, "Left border thickness.")
	_add(c, BORDER_WIDTH_TOP, ANY, null, "Top border thickness.")
	_add(c, BORDER_WIDTH_RIGHT, ANY, null, "Right border thickness.")
	_add(c, BORDER_WIDTH_BOTTOM, ANY, null, "Bottom border thickness.")
	_add(c, BORDER_RADIUS, ANY, null, "Corner radius in pixels.")
	_add(c, BORDER_RADIUS_TOP_LEFT, ANY, null, "Top-left corner radius.")
	_add(c, BORDER_RADIUS_TOP_RIGHT, ANY, null, "Top-right corner radius.")
	_add(c, BORDER_RADIUS_BOTTOM_RIGHT, ANY, null, "Bottom-right corner radius.")
	_add(c, BORDER_RADIUS_BOTTOM_LEFT, ANY, null, "Bottom-left corner radius.")
	_add(c, DROP_SHADOW_COLOR, TYPE_COLOR, null, "Drop shadow color.")
	_add(c, DROP_SHADOW_SIZE, TYPE_INT, null, "Drop shadow blur radius in pixels.")
	_add(c, DROP_SHADOW_OFFSET, ANY, null, "Drop shadow offset: a number or {x, y}.")

	_add(c, GAP, TYPE_INT, 0, "Spacing between children in pixels.")
	_add(c, WIDTH, TYPE_INT, -1, "Minimum width in pixels (-1 = unset).")
	_add(c, HEIGHT, TYPE_INT, -1, "Minimum height in pixels (-1 = unset).")
	_add(c, MAX_WIDTH, TYPE_INT, -1, "Maximum width in pixels (-1 = unlimited).")
	_add(c, MAX_HEIGHT, TYPE_INT, -1, "Maximum height in pixels (-1 = unlimited).")
	_add(c, COLUMNS, TYPE_INT, 2, "Number of columns.")
	_add(c, COLUMN_GAP, TYPE_INT, null, "Spacing between columns. Defaults to gap when unset.")
	_add(c, ROW_GAP, TYPE_INT, null, "Spacing between rows. Defaults to gap when unset.")
	_add(c, FILL_CELLS, TYPE_BOOL, true, "Makes children fill their cells. false = use content size only.")

	_add(c, DIRECTION, TYPE_STRING, "vertical", "Scrolling axes.", DIRECTIONS)
	_add(c, ALIGNMENT, TYPE_STRING, null, "Aligns children along the main axis (vertical in block, horizontal in flex).", ALIGNMENTS.keys())
	_add(c, ALIGN_ITEMS, TYPE_STRING, "stretch", "Aligns children along the cross axis (horizontal in block, vertical in flex). stretch expands children to fill the available space.", CROSS_ALIGNS.keys())
	_add(c, ALIGN_SELF, TYPE_STRING, "auto", "In block/flex, aligns this child along the cross axis. In a Stack, controls vertical alignment. Overrides the container's align_items.", [AUTO, STRETCH, START, CENTER, END])
	_add(c, JUSTIFY_SELF, TYPE_STRING, "auto", "Controls horizontal alignment in a Stack.", [AUTO, STRETCH, START, CENTER, END])
	_add(c, POINTER_EVENTS, TYPE_STRING, "auto", "none makes this component and its descendants ignore mouse input, allowing clicks to pass through to elements behind them.", [AUTO, NONE])

	_add(c, MODEL, ANY, null, "Binds the value to a store input: model = handle.model('key'). Reads the value, updates automatically, and writes back user changes.")
	_add(c, CHECKED, TYPE_BOOL, false, "Whether the control is checked.")
	_add(c, RADIO, TYPE_BOOL, false, "Makes this a radio option: users can select it but cannot deselect it directly.")
	_add(c, INDICATOR_SIZE, TYPE_INT, 20, "Indicator square size in pixels.")
	_add(c, MARK_INSET, TYPE_INT, 4, "Inset between the indicator border and its mark, in pixels.")
	_add(c, OPTION_LIST, ANY, null, "Options: a list of strings or objects with {value, label, disabled}.")
	_add(c, OPTION_CLASS, TYPE_STRING, "", "Style class applied to each option.")
	_add(c, LIST_CLASS, TYPE_STRING, "", "Style class applied to the open dropdown list.")
	_add(c, LIST_MAX_HEIGHT, TYPE_INT, 240, "Maximum height of the open dropdown list, in pixels.")
	_add(c, PLACEHOLDER, TYPE_STRING, "", "Text displayed when no option is selected.")
	_add(c, CARET, TYPE_STRING, "▾", "Text used as the dropdown indicator.")

	_add(c, FOLLOW_FOCUS, TYPE_BOOL, true, "Scrolls to keep the focused child in view.")
	_add(c, EDGE_THRESHOLD, TYPE_INT, 0, "Pixel margin used for start/end scroll events.")
	_add(c, SCROLLBAR_MODE, TYPE_STRING, "auto", "Scrollbar visibility and layout behavior.", SCROLL_MODES.keys())
	_add(c, SCROLLBAR_GAP, ANY, null, "Spacing between content and scrollbars: {vertical scrollbar, horizontal scrollbar}.")
	_add(c, SCROLLBAR_WIDTH, ANY, null, "Scrollbar thickness in pixels.")
	_add(c, SCROLLBAR_BORDER_RADIUS, ANY, null, "Corner radius for the scrollbar track and grabber.")
	_add(c, SCROLLBAR_BORDER_RADIUS_TOP_LEFT, ANY, null, "Top-left corner radius for the scrollbar track and grabber.")
	_add(c, SCROLLBAR_BORDER_RADIUS_TOP_RIGHT, ANY, null, "Top-right corner radius for the scrollbar track and grabber.")
	_add(c, SCROLLBAR_BORDER_RADIUS_BOTTOM_LEFT, ANY, null, "Bottom-left corner radius for the scrollbar track and grabber.")
	_add(c, SCROLLBAR_BORDER_RADIUS_BOTTOM_RIGHT, ANY, null, "Bottom-right corner radius for the scrollbar track and grabber.")

	_add(c, SCROLLBAR_TRACK_COLOR, TYPE_COLOR, null, "Scrollbar track color.")
	_add(c, SCROLLBAR_GRABBER_COLOR, TYPE_COLOR, null, "Scrollbar grabber color in its idle state.")
	_add(c, SCROLLBAR_GRABBER_HOVER_COLOR, TYPE_COLOR, null, "Scrollbar grabber color when hovered.")
	_add(c, SCROLLBAR_GRABBER_PRESSED_COLOR, TYPE_COLOR, null, "Scrollbar grabber color when pressed.")
	_add(c, SCROLL_HINT, TYPE_STRING, "none", "Placement of scroll indicators.", HINT_MODES.keys())
	_add(c, SCROLL_HINT_TILE, TYPE_BOOL, false, "Tiles the indicator texture instead of stretching it.")
	_add(c, SCROLL_HINT_COLOR, TYPE_COLOR, null, "Scroll indicator color.")

	_add(c, BBCODE_ENABLED, TYPE_BOOL, true, "Enables BBCode text parsing.")
	_add(c, AUTOWRAP, TYPE_STRING, WORD_SMART, "Text wrapping mode.", AUTOWRAP_MODES.keys())
	_add(c, FIT_CONTENT, TYPE_BOOL, true, "Makes the minimum size follow the content size.")
	_add(c, SCROLL_ACTIVE, TYPE_BOOL, true, "Shows a scrollbar when the text exceeds the available height.")
	_add(c, SCROLL_FOLLOWING, TYPE_BOOL, false, "Automatically scrolls to the end when text is appended (for logs and chat).")
	_add(c, SELECTION_ENABLED, TYPE_BOOL, false, "Allows text selection with the mouse.")

	_add(c, TEXT_ALIGN, TYPE_STRING, "left", "Horizontal text alignment.", H_ALIGNS.keys())
	_add(c, TEXT_VALIGN, TYPE_STRING, "top", "Vertical text alignment.", V_ALIGNS.keys())
	_add(c, UPPERCASE, TYPE_BOOL, false, "Displays all text in uppercase.")
	_add(c, TEXT_OVERFLOW, TYPE_STRING, "none", "How overflowing text is handled.", TEXT_OVERFLOWS.keys())
	_add(c, CLIP_TEXT, TYPE_BOOL, false, "Clips text horizontally to the component bounds.")
	_add(c, MAX_LINES, TYPE_INT, -1, "Maximum number of visible lines (-1 = unlimited).")
	_add(c, LINES_SKIPPED, TYPE_INT, 0, "Number of lines skipped from the beginning.")
	_add(c, VISIBLE_CHARACTERS, TYPE_INT, -1, "Number of characters to display (-1 = all). Useful for typewriter effects.")
	_add(c, VISIBLE_RATIO, TYPE_FLOAT, null, "Fraction of the text to display, from 0 to 1.")
	_add(c, AUTO_FONT_SIZE, TYPE_BOOL, false, "Adjusts the font size to fit the available space.")
	_add(c, MIN_FONT_SIZE, TYPE_INT, null, "Minimum font size when auto_font_size is enabled.")
	_add(c, MAX_FONT_SIZE, TYPE_INT, null, "Maximum font size when auto_font_size is enabled.")
	_add(c, LINE_SPACING, TYPE_INT, null, "Additional spacing between lines in pixels (may be negative).")
	_add(c, PARAGRAPH_SPACING, TYPE_INT, null, "Additional spacing between paragraphs in pixels.")
	_add(c, TEXT_SHADOW_COLOR, TYPE_COLOR, null, "Text shadow color.")
	_add(c, TEXT_SHADOW_OFFSET, ANY, null, "Text shadow offset: a number or {x, y}.")
	_add(c, TEXT_SHADOW_OUTLINE, TYPE_INT, null, "Text shadow outline thickness.")
	_add(c, META_UNDERLINED, TYPE_BOOL, true, "Underlines links created with [url].")
	_add(c, HINT_UNDERLINED, TYPE_BOOL, true, "Underlines hints created with [hint].")
	_add(c, SELECTION_COLOR, TYPE_COLOR, null, "Text selection background color.")
	_add(c, SELECTED_FONT_COLOR, TYPE_COLOR, null, "Selected text color.")
	_add(c, TAB_SIZE, TYPE_INT, 4, "Number of spaces per tab.")
	_add(c, SCROLL_FOLLOWING_VISIBLE, TYPE_BOOL, false, "Scrolls to the last visible line when visible_characters changes.")

	_add(c, FONT_SIZE, TYPE_INT, null, "Font size.")
	_add(c, FONT_COLOR, TYPE_COLOR, null, "Font color.")
	_add(c, OUTLINE_THICKNESS, TYPE_INT, null, "Font outline thickness.")
	_add(c, OUTLINE_COLOR, TYPE_COLOR, null, "Font outline color.")

	_add(c, BACKGROUND_IMAGE, TYPE_STRING, null, "Background image (9-slice). In .lcss, use texture(\"res://...\"). When an image is active, background_color, border_* and drop_shadow_* are ignored.")
	_add(c, BACKGROUND_IMAGE_TINT, TYPE_COLOR, null, "Tint color multiplied by the background image.")
	_add(c, BACKGROUND_IMAGE_STRETCH, TYPE_STRING, null, "How the image fills stretchable regions.", STRETCH_MODES.keys())
	_add(c, BACKGROUND_IMAGE_SLICE, ANY, null, "9-slice margins in pixels: a number, {horizontal, vertical}, or {left, top, right, bottom}.")
	_add(c, BACKGROUND_IMAGE_SLICE_LEFT, ANY, null, "Left 9-slice margin.")
	_add(c, BACKGROUND_IMAGE_SLICE_TOP, ANY, null, "Top 9-slice margin.")
	_add(c, BACKGROUND_IMAGE_SLICE_RIGHT, ANY, null, "Right 9-slice margin.")
	_add(c, BACKGROUND_IMAGE_SLICE_BOTTOM, ANY, null, "Bottom 9-slice margin.")

	_add(c, TRANSITION_DURATION, TYPE_FLOAT, null, "Duration in seconds for animating style property changes. Unset or 0 = no animation.")
	_add(c, TRANSITION_EASING, TYPE_STRING, null, "Animation easing curve (default: ease_out).", EASINGS.keys())
	_add(c, TRANSITION_LOOP, TYPE_STRING, null, "Animation loop mode: one_shot, ping_pong, or loop.", LOOP_OPTIONS)
	_add(c, TRANSITION_REPETITIONS, TYPE_INT, null, "Number of animation loop repetitions (default: -1, infinite).")
	_add(c, TRANSITION_PROPERTIES, ANY, null, "Properties to animate: all (default) or a list of property names.")

	_add(c, ANIMATION_NAME, TYPE_STRING, null, "Name of a .lcss @keyframes animation. Empty = no animation.")
	_add(c, ANIMATION_DURATION, TYPE_FLOAT, null, "Duration of one animation cycle, in seconds.")
	_add(c, ANIMATION_EASING, TYPE_STRING, null, "Easing curve between keyframes (default: ease_in_out).", EASINGS.keys())
	_add(c, ANIMATION_ITERATIONS, ANY, null, "Number of repetitions or infinite (default: 1).")
	_add(c, ANIMATION_DIRECTION, TYPE_STRING, null, "Animation direction: normal or alternate (forward and backward).", ANIMATION_DIRECTIONS)
	_add(c, ANIMATION_DELAY, TYPE_FLOAT, null, "Delay before the animation starts, in seconds.")
	_add(c, ANIMATION_FILL, TYPE_STRING, null, "forwards retains the final keyframe after the animation ends.", ANIMATION_FILLS)

	_add(c, TEXTURE, TYPE_STRING, "", "Sprite sheet texture path.")
	_add(c, HFRAMES, TYPE_INT, 1, "Number of columns in the sprite sheet.")
	_add(c, VFRAMES, TYPE_INT, 1, "Number of rows in the sprite sheet.")
	_add(c, FRAME_COUNT, TYPE_INT, 0, "Number of frames to use (0 = all). Useful when the last row is incomplete.")
	_add(c, FRAME, TYPE_INT, 0, "Initial frame index.")
	_add(c, FPS, TYPE_FLOAT, 12.0, "Frames per second.")
	_add(c, DURATION, TYPE_FLOAT, 0.0, "Full cycle duration in seconds. When greater than 0, overrides fps.")
	_add(c, LOOP, TYPE_BOOL, true, "Loops the animation.")
	_add(c, PLAYING, TYPE_BOOL, true, "Starts playback automatically.")

	_add(c, SCALE, ANY, null, "Visual scale: a number or {x, y}. Does not affect layout.")
	_add(c, ROTATE, TYPE_FLOAT, null, "Visual rotation in degrees. Does not affect layout.")
	_add(c, TRANSLATE, ANY, null, "Visual offset in pixels: {x, y}. Does not affect layout.")
	_add(c, TRANSFORM_ORIGIN, ANY, null, "Transform pivot point, from 0 to 1: {x, y}. Default: {0.5, 0.5}.")

	_add(c, EFFECTS, ANY, null, "Color effects applied to the component and all its descendants, in order: effect names or { effect = 'name', param = value }.")
	_add(c, EFFECT, TYPE_STRING, "tint", "Built-in screen effect.", LuaShaderLibrary.names())
	_add(c, PARAMS, ANY, null, "Effect parameters as { name = value }.")
	_add(c, ACTIVE, TYPE_BOOL, true, "Enables or disables the effect.")

	_add(c, EMITTING, TYPE_BOOL, true, "Emits particles.")
	_add(c, AMOUNT, TYPE_INT, 32, "Maximum number of live particles.")
	_add(c, LIFETIME, TYPE_FLOAT, 1.5, "Lifetime of each particle, in seconds.")
	_add(c, ONE_SHOT, TYPE_BOOL, false, "Emits particles only once. Call restart() to emit again.")
	_add(c, EXPLOSIVENESS, TYPE_FLOAT, 0.0, "0 = continuous emission; 1 = all particles emitted at once.")
	_add(c, RANDOMNESS, TYPE_FLOAT, 0.0, "Randomness of each particle's initial state, from 0 to 1.")
	_add(c, PREWARM, TYPE_FLOAT, 0.0, "Seconds simulated before the particles become visible (useful for ambient effects).")
	_add(c, SHAPE, TYPE_STRING, "box", "Emission region: point (center), box (entire rectangle), or sphere.", EMIT_SHAPES.keys())
	_add(c, EMIT_ANGLE, TYPE_FLOAT, -90.0, "Emission direction in degrees (0 = right, -90 = up).")
	_add(c, SPREAD, TYPE_FLOAT, 25.0, "Emission cone spread in degrees.")
	_add(c, SPEED, ANY, null, "Initial speed in pixels per second: a number or {min, max}. Default: {20, 60}.")
	_add(c, GRAVITY, ANY, null, "Acceleration in pixels per second squared: a number (vertical) or {x, y}.")
	_add(c, PARTICLE_SCALE, ANY, null, "Particle scale: a number or {min, max}.")
	_add(c, COLOR, TYPE_COLOR, null, "Initial particle color. Default: white.")
	_add(c, COLOR_END, TYPE_COLOR, null, "Final particle color. Defaults to the initial color with zero alpha.")
	_add(c, BLEND, TYPE_STRING, "mix", "Blend mode: mix, add (additive glow), multiply, subtract, or premultiplied_alpha.", BLENDS)
	_add(c, CLIP, TYPE_BOOL, false, "Clips particles outside the component's rectangle.")
#endregion
	return c
