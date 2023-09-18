extends State
class_name AirState

var maxSpeed = 40
var accelSpeed = 20

func Enter():
	maxSpeed = playerObj.velocity.length()
	print("Entered air state")

func Update(delta):
	var dirToMove = playerObj.direction
	var currVel = playerObj.velocity
	currVel.y = 0
	var newVel : Vector3
	
	newVel = currVel + dirToMove * delta * accelSpeed
	if newVel.length() > maxSpeed:
		newVel /= newVel.length() / maxSpeed
	
	playerObj.velocity.x = newVel.x
	playerObj.velocity.z = newVel.z
	
	playerObj.move_and_slide()
	
	if playerObj.is_on_floor():
		Transitioned.emit(self, "RunState")
	
	if Input.is_action_just_pressed("slide"):
		Transitioned.emit(self, "AirDiveState")
	
	if Input.is_action_just_pressed("slam"):
		Transitioned.emit(self, "GroundSlamState")
	
	if Input.is_action_just_pressed("attack"):
		Transitioned.emit(self, "MidAirPunchState")
