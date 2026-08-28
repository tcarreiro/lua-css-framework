extends Control

@onready var button: Button = $Button

func _ready() -> void:
	_set_gdss_classes_on_node(button, ["T1"])
	print(GDSS.get_theme_info())


static func _set_gdss_classes_on_node(node: Control, classes: Array[StringName]) -> void:
	_set_gdss_enable(node)
	_clear_gdss_classes(node)
	_add_gdss_classes_to_node(node, classes)


static func _add_gdss_classes_to_node(node: Control, classes: Array[StringName]) -> void:
	node.set_meta(GDSS.CLASSES_META, PackedStringArray(classes))
	GdssNodeHandler.refresh(node)


static func _set_gdss_inherit(node: Control) -> void:
	GdssNodeHandler.set_mode_state(node, GDSS.GdssMode.INHERIT, false)
	GdssNodeHandler.refresh(node)


static func _set_gdss_enable(node: Control) -> void:
	GdssNodeHandler.set_mode_state(node, GDSS.GdssMode.ENABLE, false)
	GdssNodeHandler.refresh(node)


static func _set_gdss_disable(node: Control) -> void:
	GdssNodeHandler.set_mode_state(node, GDSS.GdssMode.DISABLE, false)
	_clear_gdss_classes(node)


static func _clear_gdss_classes(node: Control) -> void:
	node.set_meta(GDSS.CLASSES_META, PackedStringArray([]))
	GdssNodeHandler.refresh(node)
