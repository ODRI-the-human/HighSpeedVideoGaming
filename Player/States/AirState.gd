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
	
	print("Entered air state, velocity vec: ", playerObj.velocity)
	canWallClimbOrRun = true
	playerObj.gravityActive = true
	playerObj.wasGrounded = false

func Update(delta):
	if Input.is_action_just_pressed("jump"):
		if coyoteTimer < 0.2:
			print("ass")
			playerObj.stateMachine.previous_state.DoJump()
	
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
		
	if playerObj.is_on_wall() && canWallClimbOrRun:
		canWallClimbOrRun = false
		var wallNormalNoY = -Vector3(playerObj.get_wall_normal().x, 0 , playerObj.get_wall_normal().z)
		var velocityNoY = Vector3(playerObj.lastVelocity.x, 0, playerObj.lastVelocity.z)
		var angle = wallNormalNoY.angle_to(velocityNoY.normalized())
		#var angle = Vector3(-playerObj.get_wall_normal().x, 0, -playerObj.get_wall_normal().z).normalized().angle_to(Vector3(playerObj.lastVelocity.x, 0, playerObj.lastVelocity.z).normalized())
		#print("angle: ", angle)
		print("normal: ", wallNormalNoY, " / normal mag: ", wallNormalNoY.length(), " / velocity: ", velocityNoY, " / velocity mag: ", velocityNoY.length(), " / angle: ", angle)
		if angle > deg_to_rad(45):
			playerObj.updateSpeed = false
			Transitioned.emit(self, "WallRunState")
		elif playerObj.lastVelocity.y > 20:
			playerObj.updateSpeed = false
			Transitioned.emit(self, "WallClimbState")
	
	if Input.is_action_just_pressed("slide"):
		playerObj.updateSpeed = false
		Transitioned.emit(self, "AirDiveState")
	
	if Input.is_action_just_pressed("slam"):
		playerObj.updateSpeed = false
		Transitioned.emit(self, "GroundSlamState")
	
	if Input.is_action_just_pressed("attack") && playerObj.canAirPunch:
		playerObj.updateSpeed = false
		Transitioned.emit(self, "MidAirPunchState")
