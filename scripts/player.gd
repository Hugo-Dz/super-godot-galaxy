extends CharacterBody3D

signal coin_collected

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 10
@export var planet_path : NodePath

var gravity: Vector3
var gravity_strength: float = 7
var planet_direction: Vector3 = Vector3.ZERO
var movement_input: Vector2
var gravity_velocity: Vector3 = Vector3.ZERO
var move_dir: Vector3 = Vector3.ZERO
var rotation_direction: float
var input_direction: Vector2 = Vector2.ZERO

var previously_floored = false

var projected_position: Vector3 = Vector3.ZERO

var jump_single = true
var jump_double = true
var jump_deceleration = 10.0
var is_jumping = false

var coins = 0

# Variable declared in global scope just to vizualise vectors
# Handle rotation function
var up_dir: Vector3
var current_forward: Vector3
var forward_dir: Vector3
var right_dir: Vector3
var orientation: Basis

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var debug = $DebugOverlay
@onready var model = $Character
@onready var animation = $Character/AnimationPlayer

func _ready():
	#debug.draw.add_vector(self, "planet_direction", 1, 4, Color.RED)
	#debug.draw.add_vector(self, "move_dir", 1, 4, Color.RED)
	#debug.draw.add_vector(self, "move_dir", 1, 4, Color.RED)
	#debug.draw.add_vector(self, "up_dir", 1, 4, Color.BLUE)
	pass
	

# Functions
func _physics_process(delta):
	
	# Handle functions
	handle_controls(delta)
	apply_gravity(delta)
	handle_orientation(delta, move_dir)
	handle_effects()
	
	velocity += gravity_velocity
	
	up_direction = -gravity.normalized()
	move_and_slide()
	
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)
	
	if is_on_floor() and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
		Audio.play("res://sounds/land.ogg")
	
	previously_floored = is_on_floor()
	
	projected_position = get_projected_position_on_planet()
	
	planet_direction = gravity.normalized()

# Handle animation(s)
func handle_effects():
	
	particles_trail.emitting = false
	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 0.1 or abs(velocity.z) > 0.1:
			animation.play("walk", 0.5)
			particles_trail.emitting = true
			sound_footsteps.stream_paused = false
		else:
			animation.play("idle", 0.5)
	else:
		animation.play("jump", 0.5)

# Apply gravity
func apply_gravity(delta):
	var sphere_node = get_node_or_null(planet_path)
	if sphere_node:
		var dir_to_planet_center = sphere_node.global_transform.origin - global_transform.origin
		gravity = dir_to_planet_center.normalized() * gravity_strength
		gravity_velocity += gravity * delta
		
	# Taking jump into account
	if is_jumping and gravity_velocity.dot(-gravity.normalized()) > 0:
		gravity_velocity += gravity.normalized() * jump_deceleration * delta  # Upward deceleration
	else:
		is_jumping = false
		gravity_velocity += gravity * delta

	if is_on_floor():
		gravity_velocity = gravity_velocity.lerp(Vector3.ZERO, 10 * delta)
		jump_single = true
		jump_double = true

# Handle movement input
func handle_controls(delta):
	input_direction = Vector2.ZERO
	input_direction.x = Input.get_axis("move_left", "move_right")
	input_direction.y = Input.get_axis("move_forward", "move_back")
	input_direction = input_direction.normalized()

	var right_dir = -transform.basis.x
	var forward_dir = -transform.basis.z

	move_dir = (forward_dir * input_direction.y + right_dir * input_direction.x).normalized()
	velocity = move_dir * movement_speed * delta
	
	if Input.is_action_just_pressed("jump"):
		if jump_single:
			jump_single = false
			jump_action()
		elif jump_double:
			jump_double = false
			jump_action()

# Jumping
func jump():
	
	jump_action()
	
	model.scale = Vector3(0.5, 1.5, 0.5)
	
	jump_single = false;
	jump_double = true;
	
func jump_action():
	if is_on_floor() or jump_double:
		Audio.play("res://sounds/jump.ogg")
		model.scale = Vector3(0.5, 1.5, 0.5)
		gravity_velocity = -gravity.normalized() * jump_strength
		is_jumping = true

# Collecting coins
func collect_coin():
	
	coins += 1
	
	coin_collected.emit(coins)

func handle_orientation(delta, move_dir):

	# Step 1: Align the player with the planet
	up_dir = -gravity.normalized()
	current_forward = global_transform.basis.z # This might cause the resetting while leaving keys

	# Ensure move_dir is orthogonal to up_dir
	move_dir = (move_dir - up_dir * move_dir.dot(up_dir)).normalized()

	# Calculate a forward direction. If the current forward direction 
	# is almost parallel to up_dir, choose a different reference axis for stability.
	if abs(current_forward.dot(up_dir)) > 0.98:  # nearly parallel
		current_forward = global_transform.basis.x  # Use the side vector as a reference

	# Make sure the new forward direction is orthogonal to up_dir
	forward_dir = (current_forward - up_dir * current_forward.dot(up_dir)).normalized()

	# Calculate the right direction based on the new forward and up directions
	right_dir = up_dir.cross(forward_dir).normalized()

	# Build the orientation matrix
	orientation = Basis(right_dir, up_dir, forward_dir)
	global_transform.basis = orientation
	
	
	
	# Step 2: Build face quaternion so the player always face where it goes
	var target_transform = Transform3D()
	var target_position = global_transform.origin + move_dir
	
	if velocity.length() > 0.1:
		
		if move_dir != up_dir:
			target_transform = target_transform.looking_at(move_dir, up_dir, true)
		
			var target_quaternion = Quaternion(target_transform.basis)
			quaternion = quaternion.slerp(target_quaternion, delta * 10)

func get_projected_position_on_planet() -> Vector3:
	var sphere_node = get_node_or_null(planet_path)
	if sphere_node:
		var normalized_dir = planet_direction.normalized()
		var planet_radius = sphere_node.scale.x * 0.5  # Assuming the planet is a perfect sphere with diameter = scale.x
		return sphere_node.global_transform.origin + normalized_dir * planet_radius
	return Vector3.ZERO
