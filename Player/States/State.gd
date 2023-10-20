extends Node
class_name State

signal Transitioned

@onready var playerObj = $"../.."
@onready var camera = $"../../Neck/Camera3D"

func Enter():
	pass

func Exit():
	pass

func Update(_delta: float):
	pass

func CheckIfToBecomeAirborne(): #General stuff for checking if the player should become airborne when in grounded state
	if !playerObj.is_on_floor() || (playerObj.get_floor_normal().y > playerObj.lastFloorNormal.y + 0.2 && playerObj.get_floor_normal().y == 1):
		print("television")
		playerObj.velocity = playerObj.lastVelocity.length() * playerObj.lastRealVelocity.normalized()
		playerObj.updateSpeed = false
		Transitioned.emit(self, "AirState")

func ActivateJump(normalBias): 
	#   jumpFactor is mainly used by slide, to make the player jumo higher if needed.
	playerObj.updateSpeed = false
	var speed = playerObj.lastRealVelocity.length()
	
	playerObj.velocity = (1 - 0.8 * normalBias) * playerObj.lastRealVelocity + 5 * (1 + 0.2 * speed * normalBias) * playerObj.lastFloorNormal
	Transitioned.emit(self, "AirState")

func SetJumpLandingVelocity():
	playerObj.velocity = playerObj.lastVelocity + playerObj.lastVelocity.length() * GetFloorVec()
	print("floor vec: ", GetFloorVec())

func GetFloorVec():
	var normalVec = playerObj.get_floor_normal()
	var slopeVec : Vector3
	if normalVec.y != 1:
		var rotAxisVec = Vector3(-normalVec.z, 0, normalVec.x).normalized()
		slopeVec = normalVec.rotated(rotAxisVec, deg_to_rad(90))
		if slopeVec.y > 0:
			slopeVec = -slopeVec
	else:
		slopeVec = Vector3.ZERO
	
	return slopeVec

func Physics_update(_delta: float):
	pass
