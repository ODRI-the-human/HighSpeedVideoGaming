extends State
class_name SlideState

var speed = 20
var slideTimer = 0
var dirMoving : Vector3

func Enter():
	print("Entered slide state")
	if playerObj.velocity.length() >= 1:
		dirMoving = playerObj.lastVelocity
		speed = dirMoving.length()
		dirMoving.y = 0
		dirMoving = dirMoving.normalized() * speed
	else:
		dirMoving = Vector3.ZERO
	slideTimer = 1

func Update(delta):
	playerObj.updateSpeed = true
	playerObj.move_and_slide()
	
	if !playerObj.is_on_floor():
		playerObj.velocity = playerObj.lastRealVelocity
		playerObj.updateSpeed = false
		Transitioned.emit(self, "AirState")
	
	slideTimer += delta
	var vel = dirMoving
	var slopeVec = GetFloorVec()
	
	playerObj.velocity.x = vel.x
	playerObj.velocity.z = vel.z
	dirMoving += 0.3 * slopeVec
	
	if Input.is_action_just_pressed("jump"):
		playerObj.updateSpeed = false
		playerObj.velocity.x = dirMoving.x * clamp(3 - slideTimer, 0, 3)
		playerObj.velocity.z = dirMoving.z * clamp(3 - slideTimer, 0, 3)
		playerObj.velocity.y = dirMoving.y * clamp(slideTimer, 0, 3)
		print("lol you tried to jump out of a slide, slideTimer: ", slideTimer, " / vertical vel: ", playerObj.velocity.y)
		Transitioned.emit(self, "AirState")
	
	if Input.is_action_just_released("slide"):
		playerObj.updateSpeed = false
		var newVec = -camera.get_global_transform().basis.z
		newVec.y = 0
		playerObj.velocity = newVec * playerObj.lastVelocity.length()
		Transitioned.emit(self, "RunState")
