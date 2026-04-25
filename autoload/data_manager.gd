extends Node

enum DatabaseType {
	SETTINGS,
}

enum SettingsType {
	CAMERA,
	LEVEL
}

const SETTINGS_PATH : String = "user://settings.cfg"

var _settings_data: Array[Dictionary]


func _ready() -> void:
	_load_settings()


func get_settings(type: SettingsType) -> Dictionary:
	return _settings_data[type]


func _init_schema(database_type: DatabaseType, database: Database) -> void:
	match database_type:
		DatabaseType.SETTINGS:
			database.add_valid_property("cam_move_speed", TYPE_FLOAT)
			database.add_valid_property("cam_rot_speed", TYPE_FLOAT)
			database.add_valid_property("cam_smoothing", TYPE_FLOAT)
			database.add_valid_property("grid_size", TYPE_FLOAT)


func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		var cfg_file: ConfigFile = ConfigFile.new()

		cfg_file.set_value("camera_settings", "cam_move_speed", 10.0)
		cfg_file.set_value("camera_settings", "cam_rot_speed", 75.0)
		cfg_file.set_value("camera_settings", "cam_smoothing", 0.1)
		cfg_file.set_value("level_settings", "grid_size", 2.0)

		var save_error: Error = cfg_file.save(SETTINGS_PATH)
		if save_error:
			push_error("Cannot save user settings to %s, ERROR: %s" % [SETTINGS_PATH, save_error])

	var settings_database: Database = Database.new()
	_init_schema(DatabaseType.SETTINGS, settings_database)
	settings_database.load_from_path(SETTINGS_PATH)
	_settings_data = settings_database.get_array()
