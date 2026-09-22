@tool
extends Node3D

const WHEEL_NUMBERS = [0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26]

@export var outer_radius: float = 2.0: 
	set(v): outer_radius = v; rebuild_wheel()
@export var inner_radius: float = 1.4: 
	set(v): inner_radius = v; rebuild_wheel()
@export var height: float = 0.3: 
	set(v): height = v; rebuild_wheel()

func _ready():
	rebuild_wheel()

func rebuild_wheel():
	# Clear out old geometry arrays before rebuilding
	for child in get_children():
		child.queue_free()

	var total_slots = WHEEL_NUMBERS.size()
	var angle_per_slot = TAU / total_slots

	# 1. MOVE THESE OUTSIDE THE LOOP (Declared only once)
	var mat_green = StandardMaterial3D.new(); mat_green.albedo_color = Color("017338")
	var mat_red = StandardMaterial3D.new(); mat_red.albedo_color = Color("d61c1c")
	var mat_black = StandardMaterial3D.new(); mat_black.albedo_color = Color("1a1a1a")
	var mat_gold = StandardMaterial3D.new(); mat_gold.albedo_color = Color("d4af37"); mat_gold.roughness = 0.2

	# 2. Start the loop
	for i in range(total_slots):
		var num = WHEEL_NUMBERS[i]
		
		# Align arcs so index 0 snaps straight up at 12 o'clock position
		var start_angle = (i * angle_per_slot) - (angle_per_slot / 2) - (TAU / 4)
		var end_angle = start_angle + angle_per_slot

		var active_mat = mat_black
		if num == 0: active_mat = mat_green
		elif i % 2 == 1: active_mat = mat_red

		# Generate 3D Wedge Mesh Instance
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = _create_wedge_mesh(start_angle, end_angle, active_mat)
		add_child(mesh_instance)
		
		# Add Label3D for the number text
		var label = Label3D.new()
		label.text = str(num)
		label.font_size = 48
		label.modulate = Color.WHITE
		
		# Find the center angle and radial distance for the number placement
		var mid_angle = start_angle + (angle_per_slot / 2.0)
		var text_radius = (inner_radius + outer_radius) / 2.0
		
		# Calculate 3D space position (sitting flat on the wedge surface)
		label.position = Vector3(cos(mid_angle) * text_radius, height + 0.01, sin(mid_angle) * text_radius)
		
		# Rotate the text so it faces straight up out of the wheel
		label.rotation.y = -mid_angle - (TAU / 4.0)
		label.rotation.x = deg_to_rad(-90)
		
		add_child(label)

	# Build procedural 3D wedges for each number slot
	for i in range(total_slots):
		var num = WHEEL_NUMBERS[i]
		var start_angle = (i * angle_per_slot) - (angle_per_slot / 2) - (TAU / 4)
		var end_angle = start_angle + angle_per_slot

		var active_mat = mat_black
		if num == 0: active_mat = mat_green
		elif i % 2 == 1: active_mat = mat_red

		# Generate a 3D Wedge Mesh Instance
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = _create_wedge_mesh(start_angle, end_angle, active_mat)
		add_child(mesh_instance)
		
		# Generate a 3D Divider Rim Lip Wire
		var divider = MeshInstance3D.new()
		divider.mesh = _create_divider_line(start_angle, mat_gold)
		add_child(divider)

	# Center Spindle Cone
	var spindle = MeshInstance3D.new()
	var cone = CylinderMesh.new()
	cone.top_radius = 0.0; cone.bottom_radius = inner_radius; cone.height = height * 2
	cone.material = mat_gold
	spindle.mesh = cone
	spindle.position.y = height / 2
	add_child(spindle)

func _create_wedge_mesh(start_angle: float, end_angle: float, mat: Material) -> ArrayMesh:
	var arr_mesh = ArrayMesh.new()
	var vertices = PackedVector3Array()
	var steps = 4

	# Math map building geometry faces horizontally spanning outward along the Y flat floor plane
	for s in range(steps + 1):
		var t = float(s) / steps
		var angle = lerp(start_angle, end_angle, t)
		var dir = Vector3(cos(angle), 0, sin(angle))
		
		vertices.append(dir * inner_radius) # Inner base floor
		vertices.append(dir * outer_radius) # Outer base floor
		vertices.append(dir * inner_radius + Vector3.UP * height) # Inner wall top
		vertices.append(dir * outer_radius + Vector3.UP * height) # Outer wall top

	# Standard Godot SurfaceTool bindings to clean and structure structural 3D vertex indices
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	
	# Populate structural face indices loops
	for i in range(steps):
		var base = i * 4
		# Simple 3D quad triangulations matching standard clockwise polygon windings
		st.add_vertex(vertices[base]); st.add_vertex(vertices[base+1]); st.add_vertex(vertices[base+5])
		st.add_vertex(vertices[base]); st.add_vertex(vertices[base+5]); st.add_vertex(vertices[base+4])
		st.add_vertex(vertices[base+2]); st.add_vertex(vertices[base+7]); st.add_vertex(vertices[base+3])
		st.add_vertex(vertices[base+2]); st.add_vertex(vertices[base+6]); st.add_vertex(vertices[base+7])

	st.commit(arr_mesh)
	return arr_mesh

func _create_divider_line(_angle: float, mat: Material) -> BoxMesh:
	var box = BoxMesh.new()
	box.size = Vector3(outer_radius - inner_radius, height + 0.02, 0.02)
	box.material = mat
	return box
	
	# Transform math offsets to center the structural separating dividers natively inside 3D space
	var mid_r = (inner_radius + outer_radius) / 2.0
	var container = MeshInstance3D.new()
	box.size = Vector3(outer_radius - inner_radius, height + 0.02, 0.02)
	return box
