extends State
class_name GroundSlamState

var maxSpeed = 20
var accelSpeed = 10
var timer = 0

func Enter():
	timer = 0
	print("Entered ground slam state")

func Update(delta):
	playerObj.updateSpeed = true
	playerObj.move_and_slide()
	
	if playerObj.is_on_floor():
		SetJumpLandingVelocity()
		playerObj.updateSpeed = false
		Transitioned.emit(self, "RunState")
	
	if playerObj.updateSpeed:
		timer += 2.2 * delta
	
		playerObj.velocity.x = 0
		playerObj.velocity.z = 0
		
		playerObj.velocity.y = clamp(-40 * (2 * timer), -300, 0)
