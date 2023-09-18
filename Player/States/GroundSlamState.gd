extends State
class_name GroundSlamState

var maxSpeed = 20
var accelSpeed = 10
var timer = 0

func Enter():
	timer = 0
	print("Entered ground slam state")

func Update(delta):
	timer += 3 * delta
	
	playerObj.velocity.x = 0
	playerObj.velocity.z = 0
	
	playerObj.velocity.y = clamp(-40 * (2 * timer), -120, 0)
	
	playerObj.move_and_slide()
	
	if playerObj.is_on_floor():
		Transitioned.emit(self, "RunState")
	
	if Input.is_action_just_pressed("attack"):
		Transitioned.emit(self, "MidAirPunchState")
