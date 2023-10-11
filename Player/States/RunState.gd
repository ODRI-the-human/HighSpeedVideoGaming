extends State
class_name RunState

var maxSpeed = 20
var decelSpeed = 120
var accelSpeed = 120

func Enter():
	playerObj.canAirPunch = true
	maxSpeed = clamp(playerObj.lastVelocity.length(), 20, 9999)
	
	#var angle = slopeVec.angle_to(Vector3(playerObj.lastVelocity.x, 0, playerObj.lastVelocity.z))
	print("Entered run state, lastvelocity: ", playerObj.lastVelocity.length())
	playerObj.velocity = playerObj.velocity.normalized() * playerObj.lastVelocity.length()

func Update(delta):
	playerObj.updateSpeed = true
	playerObj.move_and_slide()
	
	if playerObj.is_on_wall() && playerObj.get_floor_angle() > deg_to_rad(45): # The following is all for transitioning to the wall climb state.
		playerObj.updateSpeed = false
		print("fuck shit")
		Transitioned.emit(self, "WallClimbState")
	
	#if currNormal.y > lastFloorNormal.y && abs(lastFloorNormal.y - currNormal.y) > 0.2:
	#	print("now that's just bonkers you went over a freaking ramp buddy")
	#	playerObj.velocity = playerObj.get_real_velocity()
	#	playerObj.updateSpeed = false
	#	Transitioned.emit(self, "AirState")
	if !playerObj.is_on_floor():
		playerObj.velocity = playerObj.lastRealVelocity
		playerObj.updateSpeed = false
		Transitioned.emit(self, "AirState")
	
	if playerObj.updateSpeed:
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
		elif currVel.length() >= 3:
			newVel = currVel - currVel.normalized() * delta * decelSpeed
		else:
			newVel = Vector3.ZERO
			maxSpeed = 20 #Resets max speed if the player stops when on the floor.
		
		maxSpeed = clamp(maxSpeed, 20, 999999)
		
		playerObj.velocity = newVel
	
	if Input.is_action_pressed("slide"):
		playerObj.updateSpeed = false
		Transitioned.emit(self, "SlideState")
	
	if Input.is_action_just_pressed("jump"):
		playerObj.updateSpeed = false
		playerObj.velocity.y = playerObj.jumpVel
		Transitioned.emit(self, "AirState")
