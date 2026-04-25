extends MenuButton


enum MenuOption {
	NEW,
	OPEN,
	SAVE,
	SAVE_AS,
	QUIT
}


func _ready() -> void:
	assert(get_popup().id_pressed.connect(_on_file_menu_button_pressed) == OK)


func _on_file_menu_button_pressed(button_id: int) -> void:
	match button_id:
		MenuOption.QUIT:
			get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
			get_tree().quit()
		_:
			push_warning("file menu button not in use")
