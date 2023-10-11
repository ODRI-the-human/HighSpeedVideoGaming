extends State
class_name WallClimbState

var normalVec : Vector3
var dirMoving : Vector3
var speed : float

func Enter():
	print("Entered wall climb state")
	playerObj.canAirPunch = true
	normalVec = playerObj.get_wall_normal()
	var rotAxisVec = Vector3(-normalVec.z, 0, normalVec.x).normalized()
	
	var angle = rotAxisVec.angle_to(Vector3(playerObj.lastVelocity.x, 0, playerObj.lastVelocity.z))
	var sideVector = playerObj.lastVelocity.length() * cos(angle) * rotAxisVec
	playerObj.velocity = sideVector + Vector3(0, sqrt(pow(playerObj.lastVelocity.length(),2) - pow(sideVector.length(),2)), 0)
	
	#var dotProd = rotAxisVec.normalized().dot(playerObj.lastVelocity.normalized())
	#playerObj.velocity = Vector3.UP.rotated(normalVec, deg_to_rad(90 * dotProd)) * playerObj.lastVelocity.length()
	#print("dot prod: ", dotProd, " / new velocity: ", playerObj.velocity, " / lastOnFloorSpeed: ", playerObj.lastVelocity)
	playerObj.gravityActive = true

func Update(delta):
	playerObj.updateSpeed = true
	playerObj.move_and_slide()
	
	if !playerObj.is_on_wall():
		playerObj.updateSpeed = false
		Transitioned.emit(self, "AirState")
	
	if Input.is_action_just_pressed("jump"):
		playerObj.updateSpeed = false
		playerObj.velocity += 1.5 * normalVec * playerObj.lastVelocity.length()
		playerObj.velocity.y += playerObj.jumpVel * playerObj.lastVelocity.length()
		playerObj.velocity = playerObj.velocity.normalized() * playerObj.lastVelocity.length()
		Transitioned.emit(self, "AirState")
	
	if Input.is_action_just_pressed("slide"):
		playerObj.updateSpeed = false
		playerObj.velocity += 2.5 * normalVec
		playerObj.velocity.y = 0
		Transitioned.emit(self, "AirState")
