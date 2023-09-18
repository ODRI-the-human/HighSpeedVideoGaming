extends State
class_name RunState

var maxSpeed = 20
var decelSpeed = 120
var accelSpeed = 120

func Enter():
	print("Entered run state")
	if playerObj.velocity.length() >= 20:
		maxSpeed = playerObj.velocity.length()
	else:
		maxSpeed = 20

func Update(delta):
	accelSpeed = maxSpeed * 6
	var dirToMove = playerObj.direction
	var currVel = playerObj.velocity
	currVel.y = 0
	var newVel : Vector3
	
	if dirToMove.length() != 0:
		newVel = currVel + dirToMove * delta * accelSpeed
		if newVel.length() > maxSpeed:
			newVel /= newVel.length() / maxSpeed
			maxSpeed += 5 * delta
		elif maxSpeed > 20:
			maxSpeed = newVel.length()
	elif currVel.length() >= 1:
		newVel = currVel - currVel.normalized() * delta * decelSpeed
	else:
		newVel = Vector3.ZERO
		maxSpeed = 20 #Resets max speed if the player stops when on the floor.
	
	playerObj.velocity = newVel
	
	if Input.is_action_pressed("slide") && playerObj.velocity.length() > 0.01:
		Transitioned.emit(self, "SlideState")
	
	if Input.is_action_just_pressed("jump"):
		playerObj.velocity.y = playerObj.jumpVel
		Transitioned.emit(self, "AirState")
	
	if !playerObj.is_on_floor():
		Transitioned.emit(self, "AirState")
	
	playerObj.move_and_slide()
