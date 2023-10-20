extends Node3D

@export_group("Properties")
@export var target: Node

@export_group("Zoom")
@export var zoom_minimum = 16
@export var zoom_maximum = 4
@export var zoom_speed = 10

@export_group("Rotation")
@export var rotation_speed = 120

var camera_rotation:Vector3
var zoom = 20 # Landscape: 20, Portrait: 30
var smoothing = 0.75

var previous_pos: Vector3 = Vector3.ZERO

@onready var camera = $Camera
	

func _physics_process(delta):
	
	# Calculate the desired camera position (assuming top-down, adjust as needed)
	var camera_position = target.projected_position + target.up_dir * zoom

	# Smoothly move the camera to the desired position
	global_transform.origin = global_transform.origin.lerp(camera_position, smoothing * delta)

	# Tilt the camera slightly
	var tilt_amount = 0.1  # Adjust this value as needed (between 0 and 1)
	var tilted_up = target.up_dir.lerp(Vector3.FORWARD, tilt_amount).normalized()  # Tilted a bit towards the global forward direction

	# Look at the target while maintaining the tilted up direction
	look_at(target.projected_position, tilted_up)
	
	#handle_input(delta)

# Handle input

func handle_input(delta):

	# Rotation

	var input := Vector3.ZERO

	input.y = Input.get_axis("camera_left", "camera_right")
	input.x = Input.get_axis("camera_up", "camera_down")

	camera_rotation += input.limit_length(1.0) * rotation_speed * delta
	camera_rotation.x = clamp(camera_rotation.x, -80, -10)

	# Zooming

	zoom += Input.get_axis("zoom_in", "zoom_out") * zoom_speed * delta
	zoom = clamp(zoom, zoom_maximum, zoom_minimum)
	
	print("adjust")
