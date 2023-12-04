extends Node3D

@onready var camera = $".."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var newVec : Vector3
	newVec.x = -lerp(get_global_rotation().x, camera.get_global_rotation().x, 5 * delta)
	newVec.y = -lerp(get_global_rotation().y, camera.get_global_rotation().y, 5 * delta)
	newVec.z = lerp(get_global_rotation().z, camera.get_global_rotation().z, 5 * delta)
	set_global_rotation(newVec)
#	rotate_y(deg_to_rad(180))
