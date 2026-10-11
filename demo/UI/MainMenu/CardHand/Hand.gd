class_name HandUi extends BoxContainer

const DRAW_INITIAL_SCALE := 0.1
const DRAW_DURATION := 0.25

const HOVER_SCALE := 1.25
const HOVER_DURATION := 0.36
const HOVER_ROTATION := 0.0
const HOVER_BOTTOM_MARGIN := -17.0
const HOVER_SPREAD := 60.0
const HOVER_SPREAD_FALLOFF := 0.6 

const PLAY_DURATION := 0.4

const MOUSE_MOVEMENT_GRAB_THRESHOLD = 5

@export var card_ui_ref: PackedScene
@export var draw_position: Vector2 = Vector2(0, 0) # start draw global position

@export_category("Hand Fan")
@export var fan_width: float = 600
@export var fan_height: float = 100
@export var min_height_ratio: float = 1.54
@export var max_height_ratio: float = 1.33
@export var rotation_increment: float = 6.5
@export var x_offset_increment: float = 40
@export var y_offset_increment: float = 15
@export var starting_angle := 90
@export var children_pivot_offset_ratio := Vector2.ONE * 0.5

@onready var hand_container: Control = %HandContainer
@onready var drag_container: Control = %AbsoluteContainer

var cards : Array[CardUi] = []

var _hovering_card: CardUi = null # Card
var _holding_card: CardUi = null # Card
var _played_card: CardUi = null # Card
var _holding_outside_hand := false # whether the current holding card has already left the hand container at least once since grab
var _mouse_positon_at_grab: Vector2 = Vector2.INF

func draw_card() -> void:
	setup_new_card()
	_update_hand_and_card_positions()


func setup_new_card() -> void:
	if not card_ui_ref:
		return
	var _card = card_ui_ref.instantiate() as CardUi
	if not _card:
		return
	hand_container.add_child(_card)
	_card.name="CardUi"
	_card.pivot_offset_ratio = children_pivot_offset_ratio
	_card.scale = Vector2.ONE * DRAW_INITIAL_SCALE
	_card.set_global_position(draw_position)


func _on_child_ready(_card: CardUi) -> void:
	if not is_instance_valid(_card) or not cards.has(_card):
		return
	var slot: CardSlot = _card.get_card_slot()
	slot.is_ready = true
	if not _card.gui_input.is_connected(select_card.bind(_card)):
		_card.gui_input.connect(select_card.bind(_card))
	if not _card.mouse_entered.is_connected(_on_hover_start.bind(_card)):
		_card.mouse_entered.connect(_on_hover_start.bind(_card))
	if not _card.mouse_exited.is_connected(_on_hover_end.bind(_card)):
		_card.mouse_exited.connect(_on_hover_end.bind(_card))


func _update_hand_and_card_positions() -> void:
	var child_count := hand_container.get_child_count()
	if child_count == 0:
		custom_minimum_size = Vector2.ZERO
		return

	var angle_step := _compute_angle_step(child_count)

	for i in child_count:
		var _card := hand_container.get_child(i) as CardUi
		if not _card:
			continue
	
		if _card == _holding_card:
			continue  
	
		if _card == _hovering_card:
			_hovering_card = null
	
		if not cards.has(_card):
			cards.append(_card)
	
		var slot: CardSlot = _card.get_card_slot()
		slot.is_ready = false
		_card.pivot_offset_ratio = children_pivot_offset_ratio

		var idx := (child_count - 1 - i)
		var mid := (float(child_count - 1) / 2.0)
		var order := 0.0 if child_count == 1 else float(i - mid)/float(mid)
		
		var a := deg_to_rad(starting_angle) + idx * angle_step
		a -= (child_count - 1) * angle_step / 2.0
		a = TAU - a
		var target_rotation = order*rotation_increment
		
		var container_rect := hand_container.get_global_rect()
		var container_pivot := container_rect.position + Vector2(container_rect.size.x / 2.0, container_rect.size.y)
		var min_height = get_viewport_rect().size.y / min_height_ratio
		var max_height = get_viewport_rect().size.y / max_height_ratio
		var target_position = container_pivot - _card.size / 2.0 + Vector2(fan_width*cos(a), fan_height*sin(a))
		target_position.x += order * x_offset_increment
		target_position.y = clampf(target_position.y + abs(order)*y_offset_increment, min_height, max_height) 
	
		_card.get_card_slot().draw(Vector2.ONE, target_position, target_rotation, DRAW_DURATION)
		_card.z_index = 0
		slot.card_tween.chain().tween_callback(_on_child_ready.bind(_card))


func _compute_angle_step(child_count: int) -> float:
	if child_count <= 1:
		return 0.0
	var angle = minf(child_count * 13, 160)
	var angle_step = deg_to_rad(angle) / float(child_count - 1)
	var max_angle_step = TAU / float(child_count)
	return minf(angle_step, max_angle_step)


func _reset_all_card_slots_ready_state() -> void:
	for _card: CardUi in hand_container.get_children():
		if not cards.has(_card):
			continue
		_card.get_card_slot().is_ready = false


func _on_hover_start(_card: CardUi) -> void:
	if not cards.has(_card) or not _card.get_card_slot().is_ready: 
		return
	if _holding_card or _hovering_card == _card:
		return
	_hovering_card = _card
	_apply_hover_layout()


func _on_hover_end(_card:CardUi) -> void:
	if not cards.has(_card) or not _card.get_card_slot().is_ready: 
		return
	
	if _holding_card or _hovering_card != _card:
		return
	
	_hovering_card = null
	_apply_hover_layout()


func _hover_top(_card: CardUi) -> float:
	var pivot := _card.size * children_pivot_offset_ratio
	return get_viewport_rect().size.y - HOVER_BOTTOM_MARGIN - pivot.y - (_card.size.y - pivot.y) * HOVER_SCALE


func _apply_hover_layout() -> void:
	var children := hand_container.get_children()
	var hovered_index := children.find(_hovering_card) if _hovering_card else -1

	for i in children.size():
		var c := children[i] as CardUi
		if not c or c == _holding_card:
			continue
		var slot := c.get_card_slot()
		if not slot.is_ready:
			continue

		if i == hovered_index:
			slot.hover_start(Vector2.ONE * HOVER_SCALE, Vector2(slot.position.x, _hover_top(c)), HOVER_ROTATION, 0)
			c.z_index = 1
		else:
			var dx := 0.0
			if hovered_index != -1:
				var dist := absi(i - hovered_index)
				dx = signf(i - hovered_index) * HOVER_SPREAD * pow(HOVER_SPREAD_FALLOFF, dist - 1)
			slot.hover_start(Vector2.ONE, slot.position + Vector2(dx, 0), slot.rotation, HOVER_DURATION)
			c.z_index = 0


func _on_drag(_card: CardUi) -> void:
	_card.get_card_slot().drag(HOVER_DURATION)
	_card.z_index = 100


func _on_play(_card: CardUi) -> void:
	_card.get_card_slot().play(PLAY_DURATION)
	get_tree().create_timer(PLAY_DURATION).timeout.connect(_on_play_animation_end.bind(_card))
	_card.z_index = 100
	_played_card = null


func _on_play_animation_end(_card: CardUi) -> void:
	cards.erase(_card)
	# TODO:
	# card.get_card().play()
	_card.queue_free()


func select_card(event: InputEvent, _selected_card: CardUi) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					if _holding_card:
						if _is_mouse_in(self):
							_cancel_card(_selected_card)
					else:
						_grab_card(_selected_card)
				elif _holding_card and _holding_outside_hand:
					if absf(get_global_mouse_position().distance_to(_mouse_positon_at_grab)) >= MOUSE_MOVEMENT_GRAB_THRESHOLD:
						if _is_mouse_in(self):
							_cancel_card(_selected_card)
						else:
							_play_card(_selected_card)
				
			MOUSE_BUTTON_RIGHT:
				if _holding_card:
					_cancel_card(_selected_card)


func _grab_card(_card: CardUi) -> void:
	if not _card or _holding_card:
		return
	
	if not cards.has(_card) or not _card.get_card_slot().is_ready: 
		return
	
	var slot: CardSlot = _card.get_card_slot()
	if slot.card_tween:
		slot.card_tween.kill()
	
	_holding_card = _card
	_holding_outside_hand = false
	_mouse_positon_at_grab = get_global_mouse_position()
	_holding_card.get_card_slot().grab()


func _cancel_card(_card: CardUi) -> void:
	if not _card or _card != _holding_card:
		return
	_release_card(_card)


func _play_card(_card: CardUi) -> void:
	if not _card or _card != _holding_card:
		return
	_card.reparent(drag_container)
	_card.gui_input.disconnect(select_card.bind(_card))
	_card.mouse_entered.disconnect(_on_hover_start.bind(_card))
	_card.mouse_exited.disconnect(_on_hover_end.bind(_card))
	_played_card = _card
	_release_card(_card)


func _release_card(_card: CardUi) -> void:
	_holding_card.get_card_slot().release()
	_holding_card = null
	_mouse_positon_at_grab = Vector2.INF
	_reset_all_card_slots_ready_state()
	call_deferred("_update_hand_and_card_positions")


func _swap_card() -> void:
	if not _holding_card or not _is_mouse_in(self):
		return

	var new_index := 0
	for c in hand_container.get_children():
		if c == _holding_card or not (c is CardUi):
			continue
		var slot: CardSlot = (c as CardUi).get_card_slot()
		if slot.position.x + c.size.x / 2.0 < get_global_mouse_position().x:
			new_index += 1

	if new_index != _holding_card.get_index():
		hand_container.move_child(_holding_card, new_index)
		_update_hand_and_card_positions()


func _is_mouse_in(container: Control) -> bool:
	return container.get_global_rect().has_point(get_global_mouse_position())


func _physics_process(delta: float) -> void:
	for card in cards:
		if not is_instance_valid(card):
			continue
		card.get_card_slot().tick(delta)
	
	if _holding_card:
		_on_drag(_holding_card)
		_swap_card()
		
		if not _holding_outside_hand and not _is_mouse_in(self):
			_holding_outside_hand = true
	
	if _played_card:
		_on_play(_played_card)
