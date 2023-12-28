extends Node
class_name State

signal Transitioned

@onready var playerObj = $"../.."
@onready var upDirController = $"../../UpDirController"
@onready var becomeAirborneArea = $"../../MagnetLandArea/ColliderCircle/BecomeAirborneAreaPill"
@onready var becomeAirborneArea2 = $"../../MagnetLandArea/ColliderCircle/BecomeAirborneAreaUnder"
@onready var wallSlideEndCheckArea = $"../../MagnetLandArea/ColliderCircle/WallSlideEndCheckArea"
@onready var camera = $"../../UpDirController/Neck/Camera3D"
@onready var neck = $"../../UpDirController/Neck"
var timer = 0 # tracks how long the player has been in a state.
var startingCameraPosition : Vector3
var debugTimer : int

@export var abilName : String
@export var description : String

func SetCamPosition():
	startingCameraPosition = camera.position

func Enter():
	pass

func Exit():
	pass

func Update(_delta: float):
	pass

func CameraShit():
	#print("gomber")
	camera.position = startingCameraPosition.lerp(Vector3(0, 0, 0), 1 - pow(clamp(1 - timer * 8, 0, 1), 5))

func FrigUpColliders():
	if playerObj.becomeAirborneArea2.get_overlapping_bodies().size() > 0:
		var platformWasOn = playerObj.becomeAirborneArea2.get_overlapping_bodies()[0]
		playerObj.add_collision_exception_with(platformWasOn)

func BecomeAirborne():
	print("television, real velocity: ", playerObj.get_real_velocity(), " / player up direction: ", playerObj.up_direction)
	playerObj.velocity = playerObj.get_real_velocity()#playerObj.lastVelocity.length() * playerObj.lastRealVelocity.normalized()
	playerObj.lastVelocity = playerObj.get_real_velocity()
	playerObj.updateSpeed = false
	Transitioned.emit(self, "AirState")

func CheckIfToBecomeAirborne(): #General stuff for checking if the player should become airborne when in grounded state
	if becomeAirborneArea.get_overlapping_bodies().size() == 0:
		FrigUpColliders()
		print("reason for becoming airborne: pill collider no col")
		BecomeAirborne()
	elif becomeAirborneArea2.get_overlapping_bodies().size() == 0:
		print("reason for becoming airborne: not on floor")
		BecomeAirborne()

func ActivateJump(normalBias): 
	#   jumpFactor is mainly used by slide, to make the player jumo higher if needed.
	playerObj.wasGrounded = false
	playerObj.updateSpeed = false
	var speed = playerObj.lastRealVelocity.length()
	playerObj.lastRealVelocity -= min(playerObj.lastRealVelocity.dot(playerObj.up_direction), 0) * playerObj.up_direction
#	playerObj.lastRealVelocity.y = clamp(playerObj.lastRealVelocity.y, 0, INF)
#
#	playerObj.velocity = (1 - 0.8 * normalBias) * playerObj.lastRealVelocity.normalized() * speed + 5 * speed * (0.2 + 0.8 * normalBias) * playerObj.lastFloorNormal
	playerObj.velocity = (1 - 0.8 * normalBias) * playerObj.lastRealVelocity + playerObj.lastFloorNormal * (5 + 0.8 * normalBias * playerObj.lastRealVelocity.length())
	print("jumping, new vel: ", playerObj.velocity, " / normalBias: ", normalBias, " / dot thing: ", min(playerObj.lastRealVelocity.dot(playerObj.lastFloorNormal), 0))
	
	Transitioned.emit(self, "AirState")

func SetJumpLandingVelocity():
	var previousVelocity = playerObj.lastRealVelocity
	playerObj.velocity = playerObj.lastRealVelocity - playerObj.lastRealVelocity.dot(playerObj.get_floor_normal()) * playerObj.get_floor_normal()
	playerObj.velocity = (playerObj.velocity - playerObj.velocity.dot(playerObj.up_direction) * playerObj.up_direction).normalized() * playerObj.velocity.length()
	playerObj.lastVelocity = playerObj.velocity
	print("did an epic landing, last velocity: ", previousVelocity, " / current velocity: ", playerObj.velocity)
#	playerObj.velocity = dot * playerObj.lastVelocity
#	playerObj.velocity = playerObj.lastVelocity + playerObj.lastVelocity.length() * GetFloorVec()
#	playerObj.velocity -= playerObj.get_real_velocity().dot(playerObj.up_direction) * playerObj.get_real_velocity()
#	print("pissing: ", playerObj.get_real_velocity().normalized().dot(playerObj.up_direction.normalized()) * playerObj.get_real_velocity())
#	playerObj.velocity += GetFloorVec()
#	print("landering, velocitey: ", playerObj.lastVelocity, " / new velocity", playerObj.velocity, " / floor vec: ", GetFloorVec(), " / dot: ", playerObj.lastVelocity.dot(playerObj.get_floor_normal()))

func GetFloorVec():
	var dot = playerObj.get_floor_normal().dot(upDirController.get_global_transform().basis.y)
	if dot > 0.95:
		return Vector3.ZERO
	else:
		var rotAxisVec = playerObj.get_floor_normal().cross(upDirController.get_global_transform().basis.y).normalized()
		var rotatedVector = playerObj.get_floor_normal().rotated(rotAxisVec, deg_to_rad(270))
		if rotatedVector.dot(upDirController.get_global_transform().basis.y) > 0:
			rotatedVector = -rotatedVector
		
		return rotatedVector
	
	# Old method. Instead gonna try to do a system that uses rotation/cross product n shit
#	var normalVec = playerObj.get_floor_normal()
#	var slopeVec : Vector3
#	if abs(normalVec.y) != 1:
#		var rotAxisVec = Vector3(-normalVec.z, 0, normalVec.x).normalized()
#		slopeVec = normalVec.rotated(rotAxisVec, deg_to_rad(90))
#		if slopeVec.y > 0:
#			slopeVec = -slopeVec
#	else:
#		slopeVec = Vector3.ZERO
	
#	return slopeVec

func Physics_update(_delta: float):
	pass
