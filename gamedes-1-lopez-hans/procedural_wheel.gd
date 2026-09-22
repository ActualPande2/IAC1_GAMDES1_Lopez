@tool # Allows it to render directly inside the Godot Editor viewport
extends Node2D

# Sequence of numbers on a standard European wheel clockwise
const WHEEL_NUMBERS = [0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26]

@export var outer_radius: float = 200.0:
	set(val): outer_radius = val; queue_redraw()
@export var inner_radius: float = 140.0:
	set(val): inner_radius = val; queue_redraw()
@export var center_radius: float = 40.0:
	set(val): center_radius = val; queue_redraw()

# Standard European Roulette colors
const COLOR_GREEN = Color("017338")
const COLOR_RED = Color("d61c1c")
const COLOR_BLACK = Color("1a1a1a")
const COLOR_GOLD = Color("d4af37")

func _draw():
	var total_slots = WHEEL_NUMBERS.size()
	var angle_per_slot = TAU / total_slots # TAU is 360 degrees in radians

	# 1. Draw the Background / Outer Rim Brass Circle
	draw_circle(Vector2.ZERO, outer_radius + 10, COLOR_GOLD)
	
	# 2. Draw each number slice
	for i in range(total_slots):
		var num = WHEEL_NUMBERS[i]
		var start_angle = (i * angle_per_slot) - (angle_per_slot / 2) - (TAU / 4) # Offset by 90 deg so index 0 is top
		var end_angle = start_angle + angle_per_slot
		
		# Determine correct casino color
		var slot_color = COLOR_BLACK
		if num == 0:
			slot_color = COLOR_GREEN
		elif i % 2 == 1: # Alternating red/black sequence based on the layout array
			slot_color = COLOR_RED
			
		# Draw colored slice wedge
		_draw_doughnut_slice(Vector2.ZERO, inner_radius, outer_radius, start_angle, end_angle, slot_color)
		
		# Draw dividing gold lines between pockets
		var line_direction = Vector2.from_angle(start_angle)
		draw_line(line_direction * inner_radius, line_direction * outer_radius, COLOR_GOLD, 2.0)
		
		# 3. Draw text numbers onto the slices
		var mid_angle = start_angle + (angle_per_slot / 2)
		var text_radius = (inner_radius + outer_radius) / 2
		var text_pos = Vector2.from_angle(mid_angle) * text_radius
		
		# Calculate rotation so the text arcs nicely around the wheel facing outwards
		var text_rotation = mid_angle + (TAU / 4) 
		
		draw_set_transform(text_pos, text_rotation, Vector2.ONE)
		# Draw a placeholder string using default engine font
		draw_string(ThemeDB.fallback_font, Vector2(-8, 5), str(num), HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color.WHITE)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE) # Reset transform matrix

	# 4. Draw Center Turret / Cone Spindle
	draw_circle(Vector2.ZERO, inner_radius, COLOR_BLACK)
	draw_circle(Vector2.ZERO, center_radius, COLOR_GOLD)

# Helper function to generate math curves for arc geometry fills
func _draw_doughnut_slice(center: Vector2, r_inner: float, r_outer: float, start_rad: float, end_rad: float, color: Color):
	var points = PackedVector2Array()
	var steps = 10 # Level of curve smoothness per pocket slice
	
	# Outer curve forward
	for s in range(steps + 1):
		var a = lerp(start_rad, end_rad, float(s) / steps)
		points.append(center + Vector2.from_angle(a) * r_outer)
	# Inner curve backward
	for s in range(steps, -1, -1):
		var a = lerp(start_rad, end_rad, float(s) / steps)
		points.append(center + Vector2.from_angle(a) * r_inner)
		
	draw_polygon(points, PackedColorArray([color]))
