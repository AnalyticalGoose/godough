extends Node3D

#const MIN_ZOOM: float = 0.0
#const MAX_ZOOM: float = 20.0

var _movement_speed: float = 10.0
var _rotation_speed: float = 75.0
var _zoom_speed: float = 50.0
var _smoothing_strength: float = 0.1
var _mouse_sensitivity: float = 0.25

var _camera_pos_target: Vector3
var _camera_rot_target: float
var _camera_zoom_target: float

@export var _rotation_x_pivot: Node3D
@export var _zoom_pivot: Node3D


func _ready() -> void:
    _camera_pos_target = position
    _camera_rot_target = rotation_degrees.y
    _camera_zoom_target =  _zoom_pivot.position.z

    var camera_settings: Dictionary = DataManager.get_settings(DataManager.SettingsType.CAMERA)
    _movement_speed = camera_settings["cam_move_speed"]
    _rotation_speed = camera_settings["cam_rot_speed"]
    _zoom_speed = camera_settings["cam_zoom_speed"]
    _smoothing_strength = camera_settings["cam_smoothing"]
    _mouse_sensitivity = camera_settings["cam_mouse_sensitivity"]


func _process(delta: float) -> void:
    var input_dir: Vector2 = Input.get_vector("camera_left", "camera_right", "camera_forward", "camera_back")
    var input_axis: float = Input.get_axis("camera_rotate_right", "camera_rotate_left")
    var zoom_dir: int = (int(Input.is_action_just_released("camera_zoom_out")) -
                         int(Input.is_action_just_released("camera_zoom_in")))

    if input_dir:
        var move_dir: Vector3 = (basis * Vector3(input_dir.x, 0, input_dir.y))
        _camera_pos_target += move_dir * _movement_speed * delta
    if input_axis:
        _camera_rot_target += input_axis * _rotation_speed * delta
    if zoom_dir:
        _camera_zoom_target += zoom_dir * _zoom_speed * delta
    if _camera_pos_target != position:
        position = lerp(position, _camera_pos_target, _smoothing_strength)
    if _camera_rot_target != rotation_degrees.y:
       rotation_degrees.y = lerp(rotation_degrees.y, _camera_rot_target, _smoothing_strength)
    if _camera_zoom_target != position.z:
        _zoom_pivot.position.z = lerp(_zoom_pivot.position.z, _camera_zoom_target, _smoothing_strength)


func _unhandled_input(event: InputEvent) -> void:
    if Input.is_action_just_pressed("camera_rotate_mouse"):
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    if Input.is_action_just_released("camera_rotate_mouse"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    if event is InputEventMouseMotion and Input.is_action_pressed("camera_rotate_mouse"):
        var _event: InputEventMouseMotion = event
        _camera_rot_target -= _event.relative.x * _mouse_sensitivity
        _rotation_x_pivot.rotation_degrees.x -=  _event.relative.y * _mouse_sensitivity
