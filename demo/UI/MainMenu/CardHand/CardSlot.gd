class_name CardSlot extends RefCounted

const PLAY_FINAL_SCALE: float = 0.1
const ROTATION_SPEED: float = 15.0
const SCALE_SPEED: float = 15.0
const TRANSLATE_SPEED: float = 30.0

var card_tween: Tween
var rotation: float
var position: Vector2
var last_position: Vector2
var target_position: Vector2
var target_rotation: float = 0
var target_scale: Vector2 = Vector2.ONE
var is_ready = false
var is_dragging = false
var _max_rotation: float = 25
var _card_ui: CardUi

func _init(card: CardUi) -> void:
	_card_ui = card


func _get_transform_position() -> Vector2:
	var parent := _card_ui.get_parent() as Control
	return parent.get_global_transform() * _card_ui.position


func _set_transform_position(global_pos: Vector2) -> void:
	var parent := _card_ui.get_parent() as Control
	_card_ui.position = parent.get_global_transform().affine_inverse() * global_pos


func tick(delta: float) -> void:
	if not is_dragging:
		return
	
	var last_transform := _get_transform_position()
	var target_transform := last_transform.lerp(target_position, TRANSLATE_SPEED * delta)
	_set_transform_position(target_transform)
	target_rotation = clampf(target_transform.x - last_transform.x, -_max_rotation, _max_rotation)
	_card_ui.rotation_degrees = lerpf(_card_ui.rotation_degrees, target_rotation, ROTATION_SPEED * delta)
	_card_ui.scale = _card_ui.scale.lerp(target_scale, SCALE_SPEED * delta)


func draw(_scale: Vector2, _pos: Vector2, _rot: float, duration: float) -> void:
	target_scale = _scale
	target_position = _pos
	target_rotation = _rot
	position = target_position
	rotation = target_rotation
	animate(duration)


func drag(duration: float) -> void:
	target_position = _card_ui.get_global_mouse_position() - _card_ui.size / 2.0
	animate(duration)


func grab() -> void:
	is_dragging = true
	target_position = _card_ui.get_global_mouse_position() - _card_ui.size / 2.0
	_set_transform_position(target_position)


func play(duration: float) -> void:
	is_dragging = false
	target_position = (_card_ui.get_viewport_rect().size - _card_ui.size - Vector2(0, _card_ui.size.y)) / 2.0
	target_scale = Vector2.ONE * PLAY_FINAL_SCALE
	target_rotation = 0
	animate(duration)


func release() -> void:
	is_dragging = false


func hover_start(_scale: Vector2, _pos: Vector2, _rot: float, duration: float) -> void:
	target_scale = _scale
	target_position = _pos
	target_rotation = _rot
	animate(duration)


func hover_end(_scale: Vector2, _pos: Vector2, _rot: float, duration: float) -> void:
	target_scale = _scale
	target_position = _pos
	target_rotation = _rot
	animate(duration)


func animate(duration:float) -> void:
	if card_tween:
		card_tween.kill()

	var parent := _card_ui.get_parent() as Control
	var local_target: Vector2 = parent.get_global_transform().affine_inverse() * target_position
	
	card_tween = _card_ui.create_tween()
	card_tween.set_parallel(true)
	card_tween.set_trans(Tween.TRANS_QUAD)
	card_tween.set_ease(Tween.EASE_OUT)
	
	card_tween.tween_property(_card_ui, "scale", target_scale, duration)
	card_tween.tween_property(_card_ui, "position", local_target, duration)
	card_tween.tween_property(_card_ui, "rotation_degrees", target_rotation, duration)
	
	card_tween.chain().tween_callback(func():
		if card_tween == card_tween:
			card_tween = null
	)
