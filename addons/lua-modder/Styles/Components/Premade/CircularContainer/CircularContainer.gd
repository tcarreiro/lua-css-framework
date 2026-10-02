@tool
class_name CircularContainer extends Container

@export var radius: float = 100.0:
	set(value):
		radius = value; queue_sort()

@export_range(0.0, 360.0, 0.1) var starting_angle: float = 0.0:
	set(value):
		starting_angle = value; queue_sort()

@export_range(0.0, 360.0, 0.1) var angle: float = 360.0:
	set(value):
		angle = value; queue_sort()

@export var counter_clockwise: bool = true:
	set(value):
		counter_clockwise = value; queue_sort()

@export var split: bool = false:
	set(value):
		split = value; queue_sort()

@export var align_with_center: bool = false:
	set(value):
		align_with_center = value; queue_sort()

@export var children_pivot_offset_ratio: Vector2 = Vector2(0.5, 0.5):
	set(value):
		children_pivot_offset_ratio = value; queue_sort()

@export var tween_duration: float = 0.25
@export var tween_transition: Tween.TransitionType = Tween.TRANS_QUAD
@export var tween_ease: Tween.EaseType = Tween.EASE_OUT


func update_angle() -> void:
	angle = minf(get_child_count() * 10, 360.0)


func _notification(what: int) -> void:
	if what ==  NOTIFICATION_SORT_CHILDREN:
		update_layout()


func update_layout() -> void:
	var n = get_child_count()
	var angle_step = deg_to_rad(angle) / float(n-1)
	var final_angle = (n-1) * angle_step
	var max_angle_step = (2 * PI) / float(n)
	var max_angle = (2 * PI - max_angle_step)
	angle_step = minf(angle_step, max_angle_step)
	var offset = (n % 2) * angle_step / 2.0 * int(split)
	var start_a = deg_to_rad(starting_angle)
	for i in n:
		var side = (i % 2) * 2 - 1
		var side_ord = i / 2
		var c = get_child(i)
		c.pivot_offset_ratio = children_pivot_offset_ratio
		var a = start_a + i * angle_step
		if split:
			a = a - ((n-1) * angle_step)/2.0
		if counter_clockwise:
			a = 2.0 * PI - a
		
		var target_position: Vector2 = (size / 2.0 + radius * Vector2(cos(a), sin(a)) - c.size / 2.0)
		var target_rotation : float = 0
		if align_with_center:
			target_rotation = a + PI / 2.0
		
		var tween := create_tween()
		tween.set_trans(tween_transition)
		tween.set_ease(tween_ease)
		
		tween.tween_property(c, "position", target_position, tween_duration)
		tween.parallel().tween_property(c, "rotation", target_rotation, tween_duration)
		
		#fit_child_in_rect(c, Rect2(radius * Vector2(cos(a), sin(a)) - c.size / 2.0 + size / 2.0, Vector2.ZERO))
		#if align_with_center:
			#c.rotation = a + PI / 2.0
		
