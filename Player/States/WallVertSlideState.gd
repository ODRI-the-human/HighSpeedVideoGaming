extends State
class_name WallVertSlideState

var normalVec : Vector3
var dirMoving : Vector3
var speed : float
@onready var wallCheckAreaGuy = $"../../Area3D"

func Enter():
	playerObj.canAirPunch = true
	normalVec = playerObj.get_wall_normal()
	normalVec = ((normalVec * 10000).round() / 10000).normalized()
	var rotAxisVec = Vector3(-normalVec.z, 0, normalVec.x)
	
	var collisionLocation = playerObj.get_last_slide_collision().get_position()
	wallCheckAreaGuy.set_global_position(collisionLocation)
	print("wallCheckAreaGuy position: ", wallCheckAreaGuy.get_global_position())
	
	if playerObj.wasGrounded:
		var angle = rotAxisVec.angle_to(Vector3(playerObj.lastVelocity.x, 0, playerObj.lastVelocity.z))
		var sideVector = playerObj.lastVelocity.length() * cos(angle) * rotAxisVec
		playerObj.velocity = sideVector + Vector3(0, sqrt(pow(playerObj.lastVelocity.length(),2) - pow(sideVector.length(),2)), 0)
#	else:
#		pass #lol nothing to be done goober
	
	print("Entered wall vert slide state, velocity: ", playerObj.velocity, " / normalVec: ", normalVec)
	
	#var dotProd = rotAxisVec.normalized().dot(playerObj.lastVelocity.normalized())
	#playerObj.velocity = Vector3.UP.rotated(normalVec, deg_to_rad(90 * dotProd)) * playerObj.lastVelocity.length()
	#print("dot prod: ", dotProd, " / new velocity: ", playerObj.velocity, " / lastOnFloorSpeed: ", playerObj.lastVelocity)
	playerObj.gravityActive = true
	playerObj.wasGrounded = true
	playerObj.stateMachine.currState = PLAYERSTATES.WALLVERTSLIDE

func Update(delta):
	playerObj.updateSpeed = true
	#print("wallCheckAreaGuy position: ", wallCheckAreaGuy.get_global_position(), " / has overlapping bodies? ", wallCheckAreaGuy.has_overlapping_bodies())
	if !wallCheckAreaGuy.has_overlapping_bodies():
		playerObj.updateSpeed = false
		Transitioned.emit(self, "AirState")
		return
	
	if playerObj.is_on_floor():
		playerObj.updateSpeed = false
		Transitioned.emit(self, "RunState")
		return
	
	if playerObj.direction != Vector3.ZERO:
		var dirToMove = playerObj.direction
		var rotAxisVec = Vector3(-normalVec.z, 0, normalVec.x)
		var inputDot = dirToMove.normalized().dot(rotAxisVec.normalized())
		var glumble = 0.2 * inputDot * rotAxisVec
		print("MMMMMM YUMMY inputDot: ", inputDot)
		playerObj.velocity += glumble
	
	playerObj.move_and_slide()
	
	if Input.is_action_just_pressed("jump"):
		DoJump()
		return
	
	if Input.is_action_just_pressed("slide"):
		playerObj.updateSpeed = false
		playerObj.velocity += 2.5 * normalVec
		Transitioned.emit(self, "AirState")
		return

func DoJump():
	playerObj.wasGrounded = false
	playerObj.updateSpeed = false
	var vecto = Vector3(playerObj.lastRealVelocity.x, 0, playerObj.lastRealVelocity.z)
	var boostVec = (normalVec.normalized() + Vector3(0, 1, 0)).normalized() * max(playerObj.lastRealVelocity.length(), 20)
	playerObj.velocity = boostVec + vecto
	#playerObj.velocity += 1.5 * normalVec * playerObj.lastVelocity.length()
	#playerObj.velocity.y += playerObj.jumpVel * playerObj.lastVelocity.length()
	#playerObj.velocity = playerObj.velocity.normalized() * playerObj.lastVelocity.length()
	Transitioned.emit(self, "AirState")
	return
