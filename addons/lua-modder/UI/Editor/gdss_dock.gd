class_name LCSSDock extends EditorDock


func _init() -> void:
	title = "LCSS"
	default_slot = EditorDock.DOCK_SLOT_MAIN_SCREEN#EditorDock.DOCK_SLOT_BOTTOM
	available_layouts = EditorDock.DOCK_LAYOUT_ALL


func set_editor(editor: LCSSEditor) -> void:
	add_child(editor)
