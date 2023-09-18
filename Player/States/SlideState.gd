extends State
class_name SlideState

var speed = 20
var slideTimer = 1
var dirMoving : Vector3

func Enter():
	print("Entered slide state")
	dirMoving = playerObj.velocity
	speed = dirMoving.length()
	dirMoving.y = 0
	dirMoving = dirMoving.normalized() * speed
	slideTimer = 1

func Update(delta):
	slideTimer += delta
	
	var controlDir = playerObj.input_dir.x
	var vel = dirMoving.rotated(Vector3(0, 1, 0), -0.3 * controlDir)
	
	playerObj.velocity.x = vel.x
	playerObj.velocity.z = vel.z
	
	if Input.is_action_just_pressed("jump"):
		playerObj.velocity.y = clamp(playerObj.jumpVel * slideTimer, 0, 45)
		print("lol you tried to jump out of a slide, slideTimer: ", slideTimer, " / vertical vel: ", playerObj.velocity.y)
		Transitioned.emit(self, "AirState")
	
	if Input.is_action_just_released("slide"):
		var newVec = -camera.get_global_transform().basis.z
		newVec.y = 0
		playerObj.velocity = newVec * playerObj.velocity.length()
		Transitioned.emit(self, "RunState")
	
	if !playerObj.is_on_floor():
		Transitioned.emit(self, "AirState")
	
	playerObj.move_and_slide()