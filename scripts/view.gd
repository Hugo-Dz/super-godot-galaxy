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
var zoom: int = 20 # Landscape: 20, Portrait: 30
var smoothing: float = 0.75

var previous_pos: Vector3 = Vector3.ZERO

@onready var camera = $Camera
	

func _physics_process(delta):
	
	# Calculate the desired camera position (assuming top-down, adjust as needed)
	var camera_position: Vector3 = target.projected_position + target.up_dir * zoom

	# Smoothly move the camera to the desired position
	global_transform.origin = global_transform.origin.lerp(camera_position, smoothing * delta)

	# Tilt the camera slightly
	var tilt_amount: float = 0.1  # Adjust this value as needed (between 0 and 1)
	var tilted_up: Vector3 = target.up_dir.lerp(Vector3.FORWARD, tilt_amount).normalized()  # Tilted a bit towards the global forward direction

	# Look at the target while maintaining the tilted up direction
	# Projected position is calculated in player.gd script
	look_at(target.projected_position, tilted_up)
