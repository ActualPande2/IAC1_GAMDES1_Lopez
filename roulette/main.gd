
extends Node3D

func _ready() -> void:
	create_room()


func create_box(
		object_name: String,
		box_size: Vector3,
		box_position: Vector3,
		color: Color
) -> void:
	# Create a static physics body
	var body := StaticBody3D.new()
	body.name = object_name
	body.position = box_position
	add_child(body)

	# Create the visible mesh
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	
	var mesh := BoxMesh.new()
	mesh.size = box_size
	mesh_instance.mesh = mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.8
	mesh_instance.material_override = material

	body.add_child(mesh_instance)

	# Create collision matching the box
	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"

	var shape := BoxShape3D.new()
	shape.size = box_size
	collision.shape = shape

	body.add_child(collision)


func create_decor_box(
		object_name: String,
		box_size: Vector3,
		box_position: Vector3,
		color: Color
) -> void:
	# Decorative mesh without collision
	var obj := MeshInstance3D.new()
	obj.name = object_name

	var mesh := BoxMesh.new()
	mesh.size = box_size
	obj.mesh = mesh
	obj.position = box_position

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.45
	mat.roughness = 0.4
	obj.material_override = mat

	add_child(obj)


func create_ceiling_light(pos: Vector3) -> void:
	# Gold-colored ceiling fixture
	create_decor_box(
		"GoldLightFixture",
		Vector3(1.4, 0.12, 0.65),
		pos,
		Color(0.75, 0.48, 0.16)
	)

	# Warm light illuminating the room
	var light := OmniLight3D.new()
	light.position = pos + Vector3(0, -0.25, 0)
	light.light_color = Color(1.0, 0.72, 0.42)
	light.light_energy = 1.5
	light.omni_range = 7.0
	light.shadow_enabled = true
	add_child(light)


func create_room() -> void:
	var wall_color := Color(0.12, 0.035, 0.055)
	var gold := Color(0.78, 0.52, 0.19)
	var panel_color := Color(0.22, 0.055, 0.075)

	# Floor and ceiling
	create_box(
		"Floor", Vector3(12, 0.2, 12),
		Vector3(0, -0.1, 0),
		Color(0.10, 0.09, 0.10)
	)

	create_box(
		"Ceiling", Vector3(12, 0.2, 12),
		Vector3(0, 6, 0),
		Color(0.055, 0.045, 0.05)
	)

	# Back wall
	create_box(
		"BackWall", Vector3(12, 6, 0.2),
		Vector3(0, 3, -6),
		wall_color
	)

	# Side walls
	create_box(
		"LeftWall", Vector3(0.2, 6, 12),
		Vector3(-6, 3, 0),
		wall_color
	)

	create_box(
		"RightWall", Vector3(0.2, 6, 12),
		Vector3(6, 3, 0),
		wall_color
	)

	# Entrance in the front wall
	# Two wall sections leave a 3-unit-wide opening
	create_box(
		"FrontWallLeft", Vector3(4.5, 6, 0.2),
		Vector3(-3.75, 3, 6),
		wall_color
	)

	create_box(
		"FrontWallRight", Vector3(4.5, 6, 0.2),
		Vector3(3.75, 3, 6),
		wall_color
	)

	create_box(
		"EntranceTop", Vector3(3, 1.5, 0.2),
		Vector3(0, 5.25, 6),
		wall_color
	)

	# Gold baseboards along the side walls
	create_decor_box(
		"LeftGoldBaseboard", Vector3(0.06, 0.22, 11.7),
		Vector3(-5.87, 0.12, 0), gold
	)

	create_decor_box(
		"RightGoldBaseboard", Vector3(0.06, 0.22, 11.7),
		Vector3(5.87, 0.12, 0), gold
	)

	# Gold trim along the back wall
	create_decor_box(
		"BackGoldBaseboard", Vector3(11.7, 0.22, 0.06),
		Vector3(0, 0.12, -5.87), gold
	)

	create_decor_box(
		"BackGoldCrown", Vector3(11.7, 0.12, 0.06),
		Vector3(0, 5.65, -5.87), gold
	)

	# Decorative wall panels on the back wall
	for i in range(5):
		var x := -4.8 + i * 2.4

		create_decor_box(
			"BackPanel_%d" % i,
			Vector3(1.65, 3.6, 0.08),
			Vector3(x, 3.0, -5.82),
			panel_color
		)

		# Gold vertical panel borders
		create_decor_box(
			"PanelTrim_%d" % i,
			Vector3(0.045, 3.6, 0.04),
			Vector3(x - 0.8, 3.0, -5.75),
			gold
		)

	# Decorative panels on both side walls
	for i in range(4):
		var z := -4.5 + i * 3.0

		create_decor_box(
			"LeftPanel_%d" % i,
			Vector3(0.08, 3.2, 1.8),
			Vector3(-5.82, 3.0, z),
			panel_color
		)

		create_decor_box(
			"RightPanel_%d" % i,
			Vector3(0.08, 3.2, 1.8),
			Vector3(5.82, 3.0, z),
			panel_color
		)

	# Four warm ceiling lights
	create_ceiling_light(Vector3(-3.5, 5.65, -3.5))
	create_ceiling_light(Vector3(3.5, 5.65, -3.5))
	create_ceiling_light(Vector3(-3.5, 5.65, 2.5))
	create_ceiling_light(Vector3(3.5, 5.65, 2.5))

	# Soft ambient lighting
	var world := WorldEnvironment.new()
	var env := Environment.new()

	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.025, 0.02, 0.025)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.42, 0.40)
	env.ambient_light_energy = 0.5

	world.environment = env
	add_child(world)

	# Main directional light
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -25, 0)
	sun.light_color = Color(1.0, 0.82, 0.65)
	sun.light_energy = 0.35
	add_child(sun)
