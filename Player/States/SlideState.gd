extends State
class_name SlideState

var speed = 20
var slideTimer = 0
var dirMoving : Vector3
@onready var colliderTop = $"../../ColliderTop"

func Enter():
	print("Entered slide state")
	camera.position.y = -0.9
	colliderTop.disabled = true
	
	if playerObj.velocity.length() >= 1:
		dirMoving = playerObj.lastVelocity
		speed = dirMoving.length()
		dirMoving.y = 0
		dirMoving = dirMoving.normalized() * speed
	else:
		dirMoving = Vector3.ZERO
	slideTimer = 0

func Exit():
	camera.position.y = 0
	colliderTop.disabled = false

func Update(delta):
	playerObj.updateSpeed = true
	playerObj.move_and_slide()
	
	if !playerObj.is_on_floor():
		playerObj.velocity = playerObj.lastRealVelocity
		playerObj.updateSpeed = false
		Transitioned.emit(self, "AirState")
	
	slideTimer += 0.02 * playerObj.get_position_delta().length()
	print("slideTimer: ", slideTimer)
	var vel = dirMoving
	var slopeVec = GetFloorVec()
	
	playerObj.velocity.x = vel.x
	playerObj.velocity.z = vel.z
	dirMoving += 0.3 * slopeVec
	
	if Input.is_action_just_pressed("jump"):
		ActivateJump(clamp(slideTimer, 0, 1))
	
	if Input.is_action_just_released("slide"):
		playerObj.updateSpeed = false
		var newVec = -camera.get_global_transform().basis.z
		newVec.y = 0
		playerObj.velocity = newVec * playerObj.lastVelocity.length()
		Transitioned.emit(self, "RunState")
