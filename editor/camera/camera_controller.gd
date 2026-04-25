extends Node3D

@warning_ignore_start("unused_private_class_variable")
@export var _rotation_x_pivot: Node3D
@export var _zoom_pivot: Node3D
@export var _camera: Camera3D
@warning_ignore_restore("unused_private_class_variable")

var _movement_speed: float = 10.0
var _rotation_speed: float = 75.0
var _smoothing_strength: float = 0.1
var _camera_pos_target: Vector3
var _camera_rot_target: float


func _ready() -> void:
	_camera_pos_target = position
	_camera_rot_target = rotation_degrees.y

	var camera_settings: Dictionary = DataManager.get_settings(DataManager.SettingsType.CAMERA)
	_movement_speed = camera_settings["cam_move_speed"]
	_rotation_speed = camera_settings["cam_rot_speed"]
	_smoothing_strength = camera_settings["cam_smoothing"]


func _process(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("camera_left", "camera_right", "camera_forward", "camera_back")
	var input_axis: float = Input.get_axis("camera_rotate_right", "camera_rotate_left")

	if input_dir:
		var move_dir: Vector3 = (basis * Vector3(input_dir.x, 0, input_dir.y))
		_camera_pos_target += move_dir * _movement_speed * delta

	if input_axis:
		_camera_rot_target += input_axis * _rotation_speed * delta

	if _camera_pos_target != position:
		position = lerp(position, _camera_pos_target, _smoothing_strength)

	if _camera_rot_target != rotation_degrees.y:
		rotation_degrees.y = lerp(rotation_degrees.y, _camera_rot_target, _smoothing_strength)
