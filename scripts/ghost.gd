extends Node3D

var time: float = 0.0

var random_number = RandomNumberGenerator.new()

var random_velocity: float
var random_time: float

func _ready():
	random_velocity = random_number.randf_range(0.1, 1.0)
	random_time = random_number.randf_range(0.1, 1)

func _process(delta):

	#rotate_object_local(Vector3(0, 1, 0), deg_to_rad(90) * delta) -> simpler alternative
	
	var rotation_amount: float = deg_to_rad(90) * delta * 0.25
	var rotation_quaternion: Quaternion = Quaternion(Vector3(0, 1, 0), rotation_amount)
	var combined_rotation: Quaternion = quaternion * rotation_quaternion
	transform.basis = Basis(combined_rotation)

	var move_distance: float = (cos(time * random_time) * random_velocity) * delta
	var local_movement = transform.basis.y * move_distance

	global_transform.origin += local_movement

	time += delta
