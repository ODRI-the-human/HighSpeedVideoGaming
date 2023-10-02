extends State
class_name WallRunState

var speed = 20
var normalVec : Vector3
var dirMoving : Vector3

func Enter():
	print("Entered wall run state")
	
	normalVec = playerObj.get_wall_normal()
	var rotAxisVec = Vector3(-normalVec.z, 0, normalVec.x).normalized()
	if rotAxisVec.angle_to(playerObj.velocity) > deg_to_rad(90): # for getting correct angle.
		rotAxisVec = -rotAxisVec
	
	print("rotAxisVec: ", rotAxisVec)
	playerObj.gravityActive = false
	
	dirMoving = rotAxisVec * playerObj.velocity.length()
	speed = dirMoving.length()
	dirMoving.y = 0
	dirMoving = dirMoving.normalized() * speed

func Update(delta):
	
	var vel = dirMoving
	
	playerObj.velocity.x = vel.x
	playerObj.velocity.y = 0
	playerObj.velocity.z = vel.z
	
	if Input.is_action_just_pressed("jump"):
		playerObj.velocity.y = playerObj.jumpVel
		playerObj.velocity += 5 * normalVec
		Transitioned.emit(self, "AirState")
		playerObj.gravityActive = true
	
	if !playerObj.is_on_wall():
		Transitioned.emit(self, "AirState")
		playerObj.gravityActive = true
	
	playerObj.move_and_slide()
