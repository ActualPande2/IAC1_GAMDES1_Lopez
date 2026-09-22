extends Node2D

var radius: float = 185.0
var angle: float = 0.0
var ball_speed: float = 0.0
var spinning: bool = false


func _ready() -> void:
	queue_redraw()


func _process(delta: float) -> void:
	if spinning:
		angle += ball_speed * delta
		queue_redraw()


func _draw() -> void:
	var ball_position: Vector2 = Vector2(
		cos(angle),
		sin(angle)
	) * radius

	# Ball shadow
	draw_circle(
		ball_position + Vector2(2, 3),
		10.0,
		Color(0, 0, 0, 0.4)
	)

	# Ball
	draw_circle(
		ball_position,
		8.0,
		Color("#f5f5f5")
	)

	# Highlight
	draw_circle(
		ball_position + Vector2(-2, -2),
		2.5,
		Color("#ffffff")
	)


func start_spin() -> void:
	spinning = true
	ball_speed = 12.0


func stop_spin() -> void:
	spinning = false
	ball_speed = 0.0
