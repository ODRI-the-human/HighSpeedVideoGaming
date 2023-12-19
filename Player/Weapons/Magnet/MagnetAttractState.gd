extends State
class_name MagnetAttractState

@export var magnetState : Node
var objAttracting
var distance

func Enter():
	objAttracting = magnetState.attractObj
	distance = (objAttracting.position - playerObj.position).length()

func NewShittyRotation():
	playerObj.SetNewBasisAndShit(magnetState.attractObjNormal)
	Transitioned.emit(self, "RunState")
#	print("gomber magnet")
	magnetState.AnyStateRelease()

func Update(delta):
	if playerObj.get_last_slide_collision() != null && playerObj.get_last_slide_collision().get_collider().is_in_group("Magnetic"):
		magnetState.isOnMagneticSurface = true
		NewShittyRotation()
	
	playerObj.velocity += magnetState.magnetSign * 50 * (-playerObj.position + magnetState.attractPosition).normalized() * delta / ((playerObj.position - magnetState.attractPosition).length() / 15)
	playerObj.move_and_slide()
