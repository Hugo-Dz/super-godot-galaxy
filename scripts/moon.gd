extends Sprite3D

@export var view: Node
@export var sun: DirectionalLight3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if view and sun:
		var sun_direction: Vector3 = sun.global_transform.basis.z.normalized() 
		global_transform.origin = view.global_transform.origin + sun_direction * 200
