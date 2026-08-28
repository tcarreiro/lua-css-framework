extends Control

@onready var button: Button = $Button

func _ready() -> void:
	#_set_gdss_classes_on_node(button, ["accent"])
	GdssNodeHandler.refresh(button)
