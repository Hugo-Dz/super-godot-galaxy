extends Area3D

var time := 0.0
var grabbed := false

# Collecting coins

func _on_body_entered(body):
	if body.has_method("collect_coin") and !grabbed:
		
		body.collect_coin()
		
		Audio.play("res://sounds/coin.ogg") # Play sound
		
		$Mesh.queue_free() # Make invisible
		$Particles.emitting = false # Stop emitting stars
		
		grabbed = true

# Rotating, animating up and down

func _process(delta):
	
	var rotation_amount = deg_to_rad(90) * delta * 0.25
	var rotation_quaternion = Quaternion(Vector3(0, 1, 0), rotation_amount)
	var combined_rotation = quaternion * rotation_quaternion
	transform.basis = Basis(combined_rotation)
	
	var move_distance = (cos(time * 5) * 1) * delta
	var local_movement = transform.basis.y * move_distance

	global_transform.origin += local_movement
	
	time += delta
