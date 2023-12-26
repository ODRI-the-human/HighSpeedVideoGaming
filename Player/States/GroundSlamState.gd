extends State
class_name GroundSlamState

var maxSpeed = 20
var accelSpeed = 10

func Enter():
	print("Entered ground slam state")
	playerObj.wasGrounded = false
	playerObj.stateMachine.currState = PLAYERSTATES.AIRSLAM
	playerObj.velocity = Vector3.ZERO

func Update(delta):
	playerObj.updateSpeed = true
	playerObj.move_and_slide()
	
	if playerObj.is_on_floor():
		SetJumpLandingVelocity()
		playerObj.updateSpeed = false
		Transitioned.emit(self, "RunState")
		return
	
	if playerObj.updateSpeed:
		playerObj.velocity = -upDirController.get_global_transform().basis.y * clamp(70 * timer, 0, 150)
