@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type(
		"Notchz",
		"Control",
		preload("Notchz.gd"),
		preload("Notchz.svg"),
	)
	
func _exit_tree() -> void:
	remove_custom_type("Notchz")
