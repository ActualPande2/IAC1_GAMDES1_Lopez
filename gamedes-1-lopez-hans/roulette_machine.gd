extends Node2D

@onready var wheel: Node2D = $Wheel
@onready var ball_pivot: Node2D = $BallPivot
@onready var ball: ColorRect = $BallPivot/Ball
@onready var spin_button: Button = $SpinButton

const WHEEL_NUMBERS = [
	0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10,
	5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26
]
const TOTAL_SLOTS = 37
const DEGREES_PER_SLOT = 360.0 / TOTAL_SLOTS

var is_spinning = false
const SPIN_DURATION = 5.5
const WHEEL_ROTATIONS = 4
const BALL_ROTATIONS = 6

func _ready():
	# Wire up button interactions dynamically via code
	spin_button.pressed.connect(spin_wheel)
	
	# Center the ball perfectly on the outer track boundary based on generated wheel dimensions
	ball.position = Vector2(-ball.size.x / 2, -wheel.outer_radius + 15)

func spin_wheel():
	if is_spinning:
		return
		
	is_spinning = true
	spin_button.disabled = true
	
	# 1. Establish the target choice at the exact moment of button press
	var winning_number = WHEEL_NUMBERS.pick_random()
	var slot_index = WHEEL_NUMBERS.find(winning_number)
	
	# 2. Compute Clockwise Wheel Travel Target
	var wheel_target_rotation = wheel.rotation_degrees + (WHEEL_ROTATIONS * 360)
	
	# 3. Synchronize Counter-Clockwise Ball Orbit Path
	var slot_angle_on_wheel = slot_index * DEGREES_PER_SLOT
	var random_variance = randf_range(-DEGREES_PER_SLOT * 0.3, DEGREES_PER_SLOT * 0.3)
	
	# Calculate where the picked winning slice WILL stop inside world-space rotation
	var ball_final_slot_angle = wheel_target_rotation + slot_angle_on_wheel + random_variance
	var current_ball_modulo = int(ball_pivot.rotation_degrees) % 360
	
	# Intercept point = base multiple spins backwards + offset alignment difference
	var ball_target_rotation = ball_pivot.rotation_degrees - (BALL_ROTATIONS * 360) + (ball_final_slot_angle - current_ball_modulo)

	# 4. Construct Intertwined Smooth Animation Tweens
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# Spin layout transformations concurrently
	tween.tween_property(wheel, "rotation_degrees", wheel_target_rotation, SPIN_DURATION)
	tween.tween_property(ball_pivot, "rotation_degrees", ball_target_rotation, SPIN_DURATION)
	
	# Reset ball position to the rim edge, then slide inward toward center pockets halfway down the timeline
	ball.position.y = -wheel.outer_radius + 15
	var target_drop_y = -(wheel.inner_radius + wheel.outer_radius) / 2
	tween.tween_property(ball, "position:y", target_drop_y, SPIN_DURATION * 0.4).set_delay(SPIN_DURATION * 0.6)
	
	# 5. Connect wrap-up events when the motion safely settles down
	tween.finished.connect(func():
		is_spinning = false
		spin_button.disabled = false
		
		# Reset tracking angles to lower numbers preventing processing lag over time
		wheel.rotation_degrees = fmod(wheel.rotation_degrees, 360.0)
		ball_pivot.rotation_degrees = fmod(ball_pivot.rotation_degrees, 360.0)
		
		announce_winner(winning_number)
	)

func announce_winner(number: int):
	print("🎰 Game Complete! Resulting Winner Segment Number: ", number)
