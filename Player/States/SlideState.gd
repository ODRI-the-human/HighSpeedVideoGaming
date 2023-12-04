extends State
class_name SlideState

var speed = 20
var slideLength = 0
var dirMoving : Vector3
@onready var colliderTop = $"../../ColliderTop"
@onready var areaTop = $"../../CheckIfCanStopSliding"

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
	playerObj.wasGrounded = true
	playerObj.stateMachine.currState = PLAYERSTATES.SLIDE

func Exit():
	colliderTop.disabled = false

func CameraShit():
	camera.position = Vector3(0, 0, 0).lerp(Vector3(0, -0.9, 0), 1 - pow(clamp(1 - timer * 8, 0, 1), 5))

func Update(delta):
	playerObj.updateSpeed = true
	playerObj.move_and_slide()
	
	if !playerObj.is_on_floor():
		playerObj.velocity = playerObj.lastRealVelocity
		playerObj.updateSpeed = false
		Transitioned.emit(self, "AirDiveState")
		return
	
	CheckIfToBecomeAirborne()
	
	slideLength += 0.5 * timer
	#print("slideTimer: ", slideLength)
	var vel = dirMoving
	var slopeVec = GetFloorVec()
	
	playerObj.velocity.x = vel.x
	playerObj.velocity.z = vel.z
	dirMoving += 0.15 * slopeVec
	
	if Input.is_action_just_pressed("jump"):
		DoJump()
		return
	
	if !Input.is_action_pressed("slide") && !areaTop.has_overlapping_bodies():
		playerObj.updateSpeed = false
		var newVec = -camera.get_global_transform().basis.z
		newVec.y = 0
		playerObj.velocity = newVec * playerObj.lastVelocity.length()
		Transitioned.emit(self, "RunState")
		return

func DoJump():
	ActivateJump(clamp(slideLength, 0, 1))
	return
