extends State
class_name AirState

func Enter():
	print("Entered air state, velocity vec: ", playerObj.velocity)

func Update(delta):
	playerObj.updateSpeed = true
	playerObj.move_and_slide()
	
	if playerObj.is_on_floor():
		playerObj.updateSpeed = false
		Transitioned.emit(self, "RunState")
		
	if playerObj.is_on_wall() && playerObj.lastVelocity.y > 20:
		playerObj.updateSpeed = false
		Transitioned.emit(self, "WallClimbState")
	
	if playerObj.is_on_wall() && (-playerObj.get_wall_normal()).angle_to(playerObj.lastVelocity.normalized()) > deg_to_rad(45):
		#var angle = Vector3(-playerObj.get_wall_normal().x, 0, -playerObj.get_wall_normal().z).normalized().angle_to(Vector3(playerObj.lastVelocity.x, 0, playerObj.lastVelocity.z).normalized())
		#print("angle: ", angle)
		print("normal: ", playerObj.get_wall_normal(), " / velocity: ", playerObj.lastVelocity)
		print("angle: ", (-playerObj.get_wall_normal()).angle_to(playerObj.lastVelocity.normalized()))
		playerObj.updateSpeed = false
		Transitioned.emit(self, "WallRunState")
	
	if Input.is_action_just_pressed("slide") && playerObj.speedState > 0:
		playerObj.updateSpeed = false
		Transitioned.emit(self, "AirDiveState")
	
	if Input.is_action_just_pressed("slam"):
		playerObj.updateSpeed = false
		Transitioned.emit(self, "GroundSlamState")
	
	if Input.is_action_just_pressed("attack") && playerObj.canAirPunch:
		playerObj.updateSpeed = false
		Transitioned.emit(self, "MidAirPunchState")
