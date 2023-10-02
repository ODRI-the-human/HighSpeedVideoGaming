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

func GetFloorVec():
	var normalVec = playerObj.get_floor_normal()
	var rotAxisVec = Vector3(-normalVec.z, 0, normalVec.x).normalized()
	var slopeVec = normalVec.rotated(rotAxisVec, deg_to_rad(90))
	if slopeVec.y > 0:
		slopeVec = -slopeVec
	
	return slopeVec

func Physics_update(_delta: float):
	pass
