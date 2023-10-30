extends State
class_name GroundSlamState

var maxSpeed = 20
var accelSpeed = 10

func Enter():
	print("Entered ground slam state")
	playerObj.wasGrounded = false

func Update(delta):
	playerObj.updateSpeed = true
	playerObj.move_and_slide()
	
	if playerObj.is_on_floor():
		SetJumpLandingVelocity()
		playerObj.updateSpeed = false
		Transitioned.emit(self, "RunState")
	
	if playerObj.updateSpeed:
		playerObj.velocity.x = 0
		playerObj.velocity.z = 0
		
		playerObj.velocity.y = clamp(-40 * (4.4 * timer), -300, 0)
