extends State
class_name MagnetAttractState

@export var magnetState : Node
@export var magnetLandArea : Area3D
var indendedDirection : Vector3
var correctionDirection : Vector3
var objAttracting
var distance
var speed

func Enter():
	objAttracting = magnetState.attractObj
	distance = (objAttracting.position - playerObj.position).length()
	correctionDirection = magnetState.attractObj.get_global_transform().basis.z.normalized()
	indendedDirection = magnetState.attractObj.get_global_transform().basis.x.normalized()
	speed = playerObj.lastRealVelocity.length()
#	print("indendedDirection: ", indendedDirection)

func NewShittyRotation():
	playerObj.SetNewBasisAndShit(magnetState.attractObjNormal)
	playerObj.updateSpeed = false
#	Transitioned.emit(self, "AirState")
#	print("gomber magnet")
	magnetState.AnyStateRelease()

func Update(delta):
	var stopMeLol = false
	for body in magnetLandArea.get_overlapping_bodies():
		if body.is_in_group("Magnetic") && body.get_global_transform().basis.y == objAttracting.get_global_transform().basis.y:
			stopMeLol = true
			break
	
	if stopMeLol:
		magnetState.isOnMagneticSurface = true
		playerObj.doCheckIfNoLongerOnFloor = false
		playerObj.lastVelocity -= playerObj.velocity.dot(magnetState.attractObjNormal) * magnetState.attractObjNormal
		playerObj.velocity -= 0.8 * playerObj.velocity.dot(correctionDirection) * correctionDirection
#		playerObj.velocity = playerObj.velocity.normalized() * 40
#		playerObj.velocity -= playerObj.velocity.dot(objAttracting.get_global_transform().basis.y) * objAttracting.get_global_transform().basis.y
		NewShittyRotation()
	
#	playerObj.velocity -= 50 * magnetState.attractObjNormal * delta
	var direction = 190 * (-playerObj.position + objAttracting.position).normalized()
	direction -= direction.dot(indendedDirection) * indendedDirection
#	direction -= 1 * direction.dot(correctionDirection) * correctionDirection
#	direction += 1 * direction.dot(correctionDirection) * correctionDirection# * max((-playerObj.position + objAttracting.position).length() / 5, 1)
	direction *= delta
#	print("direction: ", direction)
#	direction = direction.normalized() * magnetState.magnetSign * delta * 50
#	direction *= magnetState.magnetSign * 50 * delta / ((playerObj.position - objAttracting.position).length() / 15)
	
	if direction.dot(-magnetState.attractObjNormal) < -0.1:
		print("mum found the piss drawer (peep show reference)")
		magnetState.AnyStateRelease()
	
	playerObj.velocity += direction
	playerObj.move_and_slide()
