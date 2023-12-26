extends State
class_name CrawlState

var dirMoving : Vector3
@onready var colliderTop = $"../../ColliderTop"
@onready var areaTop = $"../../CheckIfCanStopSliding"

func Enter():
	print("Entered crawl state")
	#camera.position.y = -0.9
	colliderTop.disabled = true
	
	playerObj.wasGrounded = true
	playerObj.stateMachine.currState = PLAYERSTATES.SLIDE

func Exit():
	colliderTop.disabled = false

func CameraShit():
	camera.position = Vector3(0, 0, 0).lerp(Vector3(0, -0.9, 0), 1 - pow(clamp(1 - timer * 8, 0, 1), 5))

func Update(delta):
	playerObj.updateSpeed = true
	playerObj.move_and_slide()
	
	if playerObj.is_on_wall() && playerObj.get_floor_normal().angle_to(upDirController.get_global_transform().basis.y) > deg_to_rad(45): # The following is all for transitioning to the wall climb state.
		playerObj.updateSpeed = false
		Transitioned.emit(self, "WallVertSlideState")
		return
	
	CheckIfToBecomeAirborne()
	
	if playerObj.updateSpeed:
		var dirToMove = playerObj.direction
		var currVel = playerObj.velocity
#		currVel.y = 0
		var newVel : Vector3
		
		
		if dirToMove.length() != 0:
			newVel = currVel + dirToMove * delta * 120
			if newVel.length() > 10:
				newVel = newVel.normalized() * 10
		elif currVel.length() >= 3:
			newVel = currVel - currVel.normalized() * delta * 120
		else:
			newVel = Vector3.ZERO
		
		playerObj.velocity = newVel
	
	if Input.is_action_just_pressed("jump") && !areaTop.has_overlapping_bodies():
		DoJump()
		return
	
	if !Input.is_action_pressed("slide") && !areaTop.has_overlapping_bodies():
		playerObj.updateSpeed = false
		var newVec = -neck.get_global_transform().basis.z
		playerObj.velocity = newVec * playerObj.lastRealVelocity.length()
		Transitioned.emit(self, "RunState")
		return

func DoJump():
	ActivateJump(0)
	return
