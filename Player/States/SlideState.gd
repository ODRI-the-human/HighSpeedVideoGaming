extends State
class_name SlideState

var speed = 20
var slideLength = 0
var dirMoving : Vector3
@onready var colliderTop = $"../../ColliderTop"

func Enter():
	print("Entered slide state")
	#camera.position.y = -0.9
	colliderTop.disabled = true
	
	if playerObj.velocity.length() >= 1:
		dirMoving = playerObj.lastVelocity
		speed = dirMoving.length()
		dirMoving.y = 0
		dirMoving = dirMoving.normalized() * speed
	else:
		dirMoving = Vector3.ZERO
	slideLength = 0
	timer = 0
	playerObj.wasGrounded = true

func Exit():
	colliderTop.disabled = false

func CameraShit():
	camera.position = Vector3(0, 0, 0).lerp(Vector3(0, -0.9, 0), 1 - pow(clamp(1 - timer * 8, 0, 1), 5))

func Update(delta):
	timer += delta
	playerObj.updateSpeed = true
	playerObj.move_and_slide()
	
	if !playerObj.is_on_floor():
		playerObj.velocity = playerObj.lastRealVelocity
		playerObj.updateSpeed = false
		Transitioned.emit(self, "AirState")
	
	CheckIfToBecomeAirborne()
	
	slideLength += 0.02 * playerObj.get_position_delta().length()
	#print("slideTimer: ", slideLength)
	var vel = dirMoving
	var slopeVec = GetFloorVec()
	
	playerObj.velocity.x = vel.x
	playerObj.velocity.z = vel.z
	dirMoving += 0.3 * slopeVec
	
	if Input.is_action_just_pressed("jump"):
		DoJump()
	
	if Input.is_action_just_released("slide"):
		playerObj.updateSpeed = false
		var newVec = -camera.get_global_transform().basis.z
		newVec.y = 0
		playerObj.velocity = newVec * playerObj.lastVelocity.length()
		Transitioned.emit(self, "RunState")

func DoJump():
	ActivateJump(clamp(slideLength, 0, 1))
