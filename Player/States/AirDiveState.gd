extends State
class_name AirDiveState

var maxSpeed = 20
var dirToFly : Vector3
var timer = 0

func Enter():
	print("Entered air dive state")
	dirToFly = playerObj.lastVelocity.length() * (-camera.get_global_transform().basis.z - 1 * Vector3(0, 1, 0)).normalized()

func Update(delta):
	playerObj.updateSpeed = true
	playerObj.move_and_slide()
	
	if playerObj.is_on_floor():
		SetJumpLandingVelocity()
		playerObj.updateSpeed = false
		Transitioned.emit(self, "RunState")
	
	if playerObj.updateSpeed:
		playerObj.velocity = dirToFly
	
	if Input.is_action_just_pressed("slam"):
		playerObj.updateSpeed = false
		Transitioned.emit(self, "GroundSlamState")
