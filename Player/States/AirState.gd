extends State
class_name AirState

var canWallClimbOrRun = true
var maxSpeed = 0
var coyoteTimer = 0

func Enter():
	maxSpeed = max(Vector3(playerObj.velocity.x, 0, playerObj.velocity.z).length(), 20)
	if playerObj.wasGrounded:
		coyoteTimer = 0
	else:
		coyoteTimer = 50
	
#	print("Entered air state, velocity vec: ", playerObj.velocity)
	canWallClimbOrRun = true
	playerObj.gravityActive = true
	playerObj.wasGrounded = false
	playerObj.stateMachine.currState = PLAYERSTATES.AIR
#	print("position: ", playerObj.position)

func Update(delta):
	if Input.is_action_just_pressed("jump"):
		if coyoteTimer < 0.2:
#			print("ass")
			playerObj.stateMachine.previous_state.DoJump()
			EndAirborne()
			return
	
	coyoteTimer += delta
	#print("coyote's timer: ", coyoteTimer)
	
	playerObj.updateSpeed = true
	var newHorVec = Vector3(playerObj.velocity.x, 0, playerObj.velocity.z) + 0.05 * playerObj.direction
	if newHorVec.length() > maxSpeed:
		newHorVec = maxSpeed * newHorVec.normalized()
	playerObj.velocity = Vector3(newHorVec.x, playerObj.velocity.y, newHorVec.z)
	playerObj.move_and_slide()

	
	if playerObj.is_on_floor():
		SetJumpLandingVelocity()
		playerObj.updateSpeed = false
		Transitioned.emit(self, "RunState")
		playerObj.camera.LandingImpact()
		EndAirborne()
		return
		
	if playerObj.is_on_wall() && canWallClimbOrRun:
		canWallClimbOrRun = false
		var wallNormalNoY = -Vector3(playerObj.get_wall_normal().x, 0 , playerObj.get_wall_normal().z)
		var velocityNoY = Vector3(playerObj.lastVelocity.x, 0, playerObj.lastVelocity.z)
		var angleHor = wallNormalNoY.angle_to(velocityNoY.normalized())
		
		if timer > 0.1:
			EndAirborne()
		
		#var rotAxisVec = Vector3(-wallNormalNoY.z, 0, wallNormalNoY.x).normalized()
		var angleVer = min(playerObj.lastVelocity.angle_to(Vector3.UP), playerObj.lastVelocity.angle_to(Vector3.DOWN))
		#var angle = Vector3(-playerObj.get_wall_normal().x, 0, -playerObj.get_wall_normal().z).normalized().angle_to(Vector3(playerObj.lastVelocity.x, 0, playerObj.lastVelocity.z).normalized())
		#print("angle: ", angle)
#		print("air wall moment, angleHor: ", rad_to_deg(angleHor), " / angleVer: ", rad_to_deg(angleVer))
		if angleHor > deg_to_rad(60) && angleVer > deg_to_rad(60) && playerObj.speedState > 0:
			playerObj.updateSpeed = false
			Transitioned.emit(self, "WallRunState")
			EndAirborne()
			return
		else:
			playerObj.updateSpeed = false
			Transitioned.emit(self, "WallVertSlideState")
			EndAirborne()
			return
	
	if Input.is_action_just_pressed("slide"):
		playerObj.updateSpeed = false
		Transitioned.emit(self, "AirDiveState")
		EndAirborne()
		return
	
	if Input.is_action_just_pressed("slam"):
		playerObj.updateSpeed = false
		Transitioned.emit(self, "GroundSlamState")
		EndAirborne()
		return
	
	if Input.is_action_just_pressed("attack") && playerObj.canAirPunch:
		pass
		#playerObj.updateSpeed = false
		#Transitioned.emit(self, "MidAirPunchState")
		#return

func EndAirborne():
	# Re-enables collision with everything; important cos the flying off platform system
	# disables collision so if you're running down a slope you don't get fucked in the bum bum
	for body in playerObj.get_collision_exceptions():
		playerObj.remove_collision_exception_with(body)
