extends State
class_name MidAirPunchState

var maxSpeed = 20
var dirToFly : Vector3

func Enter():
	print("Entered mid-air punch state")
	playerObj.canAirPunch = false
	timer = 0
	dirToFly = -playerObj.lastVelocity.length() * camera.get_global_transform().basis.z
	playerObj.wasGrounded = false
	playerObj.stateMachine.currState = PLAYERSTATES.AIRPUNCH

func Update(delta):
	playerObj.updateSpeed = true
	playerObj.move_and_slide()
	
	if timer > 0.2:
		Transitioned.emit(self, "AirState")
		return
	
	playerObj.velocity = dirToFly
	timer += delta
