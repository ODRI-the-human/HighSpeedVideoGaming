extends State
class_name AirDiveState

var maxSpeed = 20
var dirToFly : Vector3
var timer = 0

func Enter():
	print("Entered air dive state")
	dirToFly = -playerObj.velocity.length() * camera.get_global_transform().basis.z
	dirToFly.y = -40

func Update(delta):
	playerObj.velocity = dirToFly
	playerObj.move_and_slide()
	
	if playerObj.is_on_floor():
		Transitioned.emit(self, "RunState")
