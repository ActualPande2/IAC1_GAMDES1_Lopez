extends Node3D

@onready var wheel: Node3D = $Wheel3D
@onready var ball_pivot: Node3D = $BallPivot3D
@onready var ball: MeshInstance3D = $BallPivot3D/Ball3D
@onready var spin_button: Button = $SpinButton

const WHEEL_NUMBERS = [0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26]
const TOTAL_SLOTS = 37
const DEGREES_PER_SLOT = 360.0 / TOTAL_SLOTS

var is_spinning = false
const SPIN_DURATION = 5.5
const WHEEL_ROTATIONS = 4
const BALL_ROTATIONS = 6

func _ready():
	spin_button.pressed.connect(spin_wheel)
	# Snap ball perfectly onto the top lip rim of our procedurally built 3D bounds track
	ball.position = Vector3(0, wheel.height + 0.05, -wheel.outer_radius + 0.1)

func spin_wheel():
	if is_spinning:
		return
		
	is_spinning = true
	spin_button.disabled = true
	
	var winning_number = WHEEL_NUMBERS.pick_random()
	var slot_index = WHEEL_NUMBERS.find(winning_number)
	
	# 3D transforms use the standard Y-axis for horizontal wheel rotations
	var wheel_target_rotation = wheel.rotation_degrees.y + (WHEEL_ROTATIONS * 360)
	
	var slot_angle_on_wheel = slot_index * DEGREES_PER_SLOT
	var random_variance = randf_range(-DEGREES_PER_SLOT * 0.3, DEGREES_PER_SLOT * 0.3)
	
	var ball_final_slot_angle = wheel_target_rotation + slot_angle_on_wheel + random_variance
	var current_ball_modulo = int(ball_pivot.rotation_degrees.y) % 360
	
	# Lock counter-clockwise math tracks targeting future intersection frame vectors
	var ball_target_rotation = ball_pivot.rotation_degrees.y - (BALL_ROTATIONS * 360) + (ball_final_slot_angle - current_ball_modulo)

	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# Animate along Vector3 Y rotational space properties
	tween.tween_property(wheel, "rotation_degrees:y", wheel_target_rotation, SPIN_DURATION)
	tween.tween_property(ball_pivot, "rotation_degrees:y", ball_target_rotation, SPIN_DURATION)
	
	# Spiral drop ball inward along Z depth boundaries matching our inner pocket drop zones halfway through timeline
	ball.position.z = -wheel.outer_radius + 0.1
	var target_drop_z = -(wheel.inner_radius + wheel.outer_radius) / 2.0
	tween.tween_property(ball, "position:z", target_drop_z, SPIN_DURATION * 0.4).set_delay(SPIN_DURATION * 0.6)
	
	# Clean up operations completion callback
	tween.finished.connect(func():
		is_spinning = false
		spin_button.disabled = false
		
		wheel.rotation_degrees.y = fmod(wheel.rotation_degrees.y, 360.0)
		ball_pivot.rotation_degrees.y = fmod(ball_pivot.rotation_degrees.y, 360.0)
		
		print("🎰 3D Ball landed on: ", winning_number)
	)
