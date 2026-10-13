
extends CharacterBody3D

@export var move_speed: float = 5.0
@export var mouse_sensitivity: float = 0.002

var gravity: float = 9.8

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(
			head.rotation.x,
			deg_to_rad(-85),
			deg_to_rad(85)
		)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton:
		if event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir := Vector2(
		Input.get_action_strength("move_right")
			- Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back")
			- Input.get_action_strength("move_forward")
	)

	input_dir = input_dir.normalized()

	var direction := (
		transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	move_and_slide()
