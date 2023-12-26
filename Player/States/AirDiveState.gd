extends State
class_name AirDiveState

var maxSpeed = 20
var dirToFly : Vector3

func Enter():
	print("Entered air dive state")
	dirToFly = clamp(playerObj.lastVelocity.length(), 30, INF) * (-camera.get_global_transform().basis.z - 1 * upDirController.get_global_transform().basis.y).normalized()
	playerObj.lastVelocity = dirToFly
	playerObj.wasGrounded = false
	playerObj.stateMachine.currState = PLAYERSTATES.AIRDIVE

func Update(delta):
	playerObj.updateSpeed = false
	playerObj.velocity = dirToFly
	playerObj.move_and_slide()
	
	if timer > 0.4:
		playerObj.updateSpeed = false
		Transitioned.emit(self, "AirState")
	
	if playerObj.is_on_wall():
		playerObj.updateSpeed = false
		Transitioned.emit(self, "AirState")
		return
	
	if playerObj.is_on_floor():
#		SetJumpLandingVelocity()
		playerObj.updateSpeed = false
		Transitioned.emit(self, "RunState")
		return
	
	if Input.is_action_just_pressed("slam"):
		playerObj.updateSpeed = false
		Transitioned.emit(self, "GroundSlamState")
		return
