@tool
class_name CircularContainer extends Container

signal child_ready(child: Node)

@export var radius_x: float = 100.0:
	set(value):
		radius_x = value; queue_sort()

@export var radius_y: float = 100.0:
	set(value):
		radius_y = value; queue_sort()

@export_range(0.0, 360.0, 0.1) var starting_angle: float = 0.0:
	set(value):
		starting_angle = value; queue_sort()

@export_range(0.0, 360.0, 0.1) var max_angle: float = 360.0:
	set(value):
		max_angle = value; queue_sort()

@export var counter_clockwise: bool = true:
	set(value):
		counter_clockwise = value; queue_sort()

@export var mirror: bool = true:
	set(value):
		mirror = value; queue_sort()

@export var split: bool = false:
	set(value):
		split = value; queue_sort()

@export var align_with_center: bool = false:
	set(value):
		align_with_center = value; queue_sort()

@export var children_pivot_offset_ratio: Vector2 = Vector2(0.5, 0.5):
	set(value):
		children_pivot_offset_ratio = value; queue_sort()

@export_category("Animation")
@export var animate: bool = false
@export var tween_duration: float = 0.25
@export var tween_transition: Tween.TransitionType = Tween.TRANS_QUAD
@export var tween_ease: Tween.EaseType = Tween.EASE_OUT

var angle: float = 0.0:
	set(value):
		angle = value; queue_sort()


func set_angle(_ang: float) -> void:
	angle = minf(_ang, max_angle)


func _notification(what: int) -> void:
	if what ==  NOTIFICATION_SORT_CHILDREN:
		update_layout()


func _compute_angle_step(child_count: int) -> float:
	if child_count <= 1:
		return 0.0
	var angle_step = deg_to_rad(angle) / float(child_count - 1)
	var max_angle_step = TAU / float(child_count)
	return minf(angle_step, max_angle_step)


func update_layout() -> void:
	var n := get_child_count()
	if n == 0:
		custom_minimum_size = Vector2.ZERO
		return

	var max_extent_x := 0.0
	var max_extent_y := 0.0
	for i in n:
		var c := get_child(i)
		if c is Control:
			max_extent_x = maxf(max_extent_x, c.size.x / 2.0)
			max_extent_y = maxf(max_extent_y, c.size.y / 2.0)

	var effective_x := radius_x + max_extent_x
	var effective_y := radius_y + max_extent_y
	custom_minimum_size = Vector2(effective_x * 2.0, effective_y * 2.0)
	var center := Vector2(effective_x, effective_y)

	var angle_step := _compute_angle_step(n)

	for i in n:
		var c := get_child(i)
		if not (c is Control):
			continue
		c.pivot_offset_ratio = children_pivot_offset_ratio

		var idx := (n - 1 - i) if mirror else i
		var a := deg_to_rad(starting_angle) + idx * angle_step
		if split:
			a -= (n - 1) * angle_step / 2.0
		if counter_clockwise:
			a = TAU - a

		var child_position: Vector2 = center + Vector2(radius_x * cos(a), radius_y * sin(a)) - c.size / 2.0

		var target_rotation := 0.0
		if align_with_center:
			target_rotation = a + PI / 2.0
			target_rotation = c.rotation + wrapf(target_rotation - c.rotation, -PI, PI)
		
		if animate:
			var tween := create_tween()
			tween.set_trans(tween_transition)
			tween.set_ease(tween_ease)
			tween.tween_property(c, "position", child_position, tween_duration)
			tween.parallel().tween_property(c, "rotation", target_rotation, tween_duration)
			tween.finished.connect(child_ready.emit.bind(c))
		else:
			c.position = child_position
			c.rotation = target_rotation
			child_ready.emit(c)
