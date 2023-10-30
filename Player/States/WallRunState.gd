extends State
class_name WallRunState

var speed = 20
var normalVec : Vector3
var dirMoving : Vector3

func GetWallNormal():
	normalVec = playerObj.get_wall_normal()
	var rotAxisVec = Vector3(-normalVec.z, 0, normalVec.x).normalized()
	if rotAxisVec.angle_to(playerObj.lastVelocity) > deg_to_rad(90): # for getting correct angle.
		rotAxisVec = -rotAxisVec
	
	#print("rotAxisVec: ", rotAxisVec)
	playerObj.gravityActive = false
	
	dirMoving = rotAxisVec * playerObj.lastVelocity.length()
	speed = dirMoving.length()
	dirMoving.y = 0
	dirMoving = dirMoving.normalized() * speed

func Enter():
	print("Entered wall run state")
	playerObj.canAirPunch = true
	GetWallNormal()
	playerObj.wasGrounded = true

func Update(delta):
	playerObj.updateSpeed = true
	playerObj.velocity -= 0.2 * normalVec
	playerObj.move_and_slide()
	
	if !playerObj.is_on_wall():
		playerObj.updateSpeed = false
		Transitioned.emit(self, "AirState")
		playerObj.gravityActive = true
	
	playerObj.velocity.x = dirMoving.x
	playerObj.velocity.y = 0
	playerObj.velocity.z = dirMoving.z
	#playerObj.velocity -= normalVec * 2 # Otherwise the player can become unstuck from the wall.
	
	if Input.is_action_just_pressed("jump"):
		DoJump()
	
	if Input.is_action_just_pressed("slide"):
		playerObj.updateSpeed = false
		playerObj.velocity += 2.5 * normalVec
		Transitioned.emit(self, "AirState")
		playerObj.gravityActive = true
	
	var currNormVec = playerObj.get_wall_normal()
	
	if currNormVec != normalVec && currNormVec != Vector3.ZERO:
		GetWallNormal()

func DoJump():
	playerObj.wasGrounded = false
	playerObj.updateSpeed = false
	playerObj.velocity.y = playerObj.jumpVel
	playerObj.velocity += 5 * normalVec
	Transitioned.emit(self, "AirState")
	playerObj.gravityActive = true
