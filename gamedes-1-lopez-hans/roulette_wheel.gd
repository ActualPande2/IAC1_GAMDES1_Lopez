extends Node2D

@onready var ball: Node2D = $"../Ball"

const WHEEL_RADIUS: float = 220.0
const OUTER_RADIUS: float = 245.0
const POCKET_COUNT: int = 37

const RED: Color = Color("#b51f2a")
const BLACK: Color = Color("#171717")
const GREEN: Color = Color("#087f4f")
const GOLD: Color = Color("#d4af5a")
const CREAM: Color = Color("#f4e6bd")

var numbers: Array[int] = [
	0,
	32, 15, 19, 4, 21, 2, 25, 17, 34,
	6, 27, 13, 36, 11, 30, 8, 23, 10, 5,
	24, 16, 33, 1, 20, 14, 31, 9, 22, 18,
	29, 7, 28, 12, 35, 3, 26
]

var red_numbers: Array[int] = [
	1, 3, 5, 7, 9,
	12, 14, 16, 18,
	19, 21, 23, 25, 27,
	30, 32, 34, 36
]

var spinning: bool = false
var wheel_speed: float = 0.0
var target_speed: float = 0.0

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	if spinning:
		wheel_speed = move_toward(
			wheel_speed,
			target_speed,
			8.0 * delta
		)
		rotation += wheel_speed * delta

func _draw() -> void:
	draw_wheel()


func draw_wheel() -> void:
	var center: Vector2 = Vector2.ZERO

	# Outer shadow
	draw_circle(
		center + Vector2(0, 8),
		OUTER_RADIUS + 5,
		Color(0, 0, 0, 0.35)
	)

	# Outer gold rim
	draw_circle(
		center,
		OUTER_RADIUS,
		GOLD
	)

	# Inner dark rim
	draw_circle(
		center,
		OUTER_RADIUS - 12,
		Color("#3b2a16")
	)

	# Main wheel
	draw_circle(
		center,
		WHEEL_RADIUS,
		Color("#272727")
	)

	draw_pockets()
	draw_center_hub()

func spin() -> void:
	if spinning:
		return

	spinning = true
	wheel_speed = 12.0
	
	ball.start_spin()

	await get_tree().create_timer(3.0).timeout
	
	target_speed = 0.0
	
	await get_tree().create_timer(4.0).timeout

	spinning = false
	wheel_speed = 0.0
	
	ball.stop_spin()

func draw_pockets() -> void:
	var pocket_angle: float = TAU / float(POCKET_COUNT)

	for i: int in range(POCKET_COUNT):
		var start_angle: float = -PI / 2.0 + i * pocket_angle
		var end_angle: float = start_angle + pocket_angle

		var number: int = numbers[i]

		var color: Color = get_number_color(number)

		# Pocket
		draw_colored_polygon(
			create_wedge(
				Vector2.ZERO,
				15.0,
				WHEEL_RADIUS - 5.0,
				start_angle,
				end_angle
			),
			color
		)

		# Pocket divider
		draw_line(
			Vector2(cos(start_angle), sin(start_angle)) * 15.0,
			Vector2(cos(start_angle), sin(start_angle)) * (WHEEL_RADIUS - 5.0),
			GOLD,
			2.0
		)

		# Number
		var middle_angle: float = (start_angle + end_angle) / 2.0

		var number_position: Vector2 = Vector2(
			cos(middle_angle),
			sin(middle_angle)
		) * (WHEEL_RADIUS - 45.0)

		draw_number(
			str(number),
			number_position,
			middle_angle
		)


func create_wedge(
	center: Vector2,
	inner_radius: float,
	outer_radius: float,
	start_angle: float,
	end_angle: float
) -> PackedVector2Array:

	var points: PackedVector2Array = PackedVector2Array()

	var steps: int = 8

	# Inner arc
	for i: int in range(steps + 1):
		var progress: float = float(i) / float(steps)
		var angle: float = lerp(start_angle, end_angle, progress)

		points.append(
			center + Vector2(
				cos(angle),
				sin(angle)
			) * inner_radius
		)

	# Outer arc
	for i: int in range(steps, -1, -1):
		var progress: float = float(i) / float(steps)
		var angle: float = lerp(start_angle, end_angle, progress)

		points.append(
			center + Vector2(
				cos(angle),
				sin(angle)
			) * outer_radius
		)

	return points


func get_number_color(number: int) -> Color:

	if number == 0:
		return GREEN

	if number in red_numbers:
		return RED

	return BLACK


func draw_number(
	text: String,
	text_position: Vector2,
	angle: float
) -> void:

	var font: Font = ThemeDB.fallback_font
	var font_size: int = 18

	var text_size: Vector2 = font.get_string_size(
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size
	)

	var text_transform: Transform2D = Transform2D(
		angle + PI / 2.0,
		text_position
	)

	draw_set_transform(
		text_transform.origin,
		text_transform.get_rotation(),
		Vector2.ONE
	)

	draw_string(
		font,
		Vector2(
			-text_size.x / 2.0,
			text_size.y / 2.0
		),
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		CREAM
	)

	draw_set_transform(
		Vector2.ZERO,
		0.0,
		Vector2.ONE
	)


func draw_center_hub() -> void:

	# Wooden center
	draw_circle(
		Vector2.ZERO,
		70.0,
		Color("#8b642e")
	)

	# Gold ring
	draw_arc(
		Vector2.ZERO,
		70.0,
		0.0,
		TAU,
		64,
		GOLD,
		6.0
	)

	# Inner gold section
	draw_circle(
		Vector2.ZERO,
		48.0,
		Color("#c9a54f")
	)

	# Dark center
	draw_circle(
		Vector2.ZERO,
		35.0,
		Color("#4b3519")
	)

	# Center cap
	draw_circle(
		Vector2.ZERO,
		20.0,
		Color("#d7b45c")
	)
