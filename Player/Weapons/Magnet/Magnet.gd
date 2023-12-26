extends Weapon
class_name Magnet

@export var rayCaster : RayCast3D
@export var reticle : Node3D
@export var skeleton : Skeleton3D
var attractObj
var attractPosition
var magnetSign : int
var isMagnetting : bool
var isOnMagneticSurface = false

@export var ColliderCircle : Node3D
@export var ColliderTop : Node3D
@export var ColliderBottom : Node3D
var attractObjNormal : Vector3
var currentUp : Vector3
var angle : float
@export var magnetGroundDetector : Area3D
var surfaceCheckTimer = 0

# the following is for the flipping cam trick
var rotateTimer = 0
var totalFrac = 0
var lastFracEased = 0
var totalAngleRotated = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	isMagnetting = false
	currentUp = playerObj.up_direction

func Attack():
	var castObj = rayCaster.get_collider()
	if castObj != null:
		if castObj.is_in_group("Magnetic"):
			MagnetMoment(1, castObj, rayCaster.get_collision_point())

func Alt():
	var castObj = rayCaster.get_collider()
	if castObj != null:
		if castObj.is_in_group("Magnetic"):
			MagnetMoment(-1, castObj, rayCaster.get_collision_point())

func MagnetMoment(sign : int, castObj, pos):
#	if isOnMagneticSurface:
#		upDirController.rotate(upDirController.get_global_transform().basis.x, -totalAngleRotated)
	playerObj.SetNewBasisAndShit(Vector3(0, 1, 0))
	isOnMagneticSurface = false
	currentUp = upDirController.get_global_transform().basis.y
	attractObjNormal = -castObj.get_global_transform().basis.y
	angle = currentUp.signed_angle_to(attractObjNormal, playerObj.get_global_transform().basis.x)
#	if angle > 0:
#		angle = -angle
#	angle = currentUp.signed_angle_to(attractObjNormal, Vector3.UP) - totalAngleRotated
	attractObj = castObj
	attractPosition = pos
	magnetSign = sign
	print("pooping currently, attractObjNormal: ", attractObjNormal, " / currentUp: ", currentUp, " / angle: ", rad_to_deg(angle))
	playerObj.stateMachine.animPlayer.play("grapThrow")
	Transitioned.emit(self, "MagnetAttractState")
	isMagnetting = true
	InvertColliders(true)
	totalFrac = 0
	lastFracEased = 0
	rotateTimer = 0

func AltRelease():
	pass
#	AnyStateRelease()

func Release():
	pass
#	AnyStateRelease()

func InvertColliders(circle : bool):
	if circle:
		ColliderCircle.disabled = false
		ColliderTop.disabled = true
		ColliderBottom.disabled = true
	else:
		ColliderCircle.disabled = true
		ColliderTop.disabled = false
		ColliderBottom.disabled = false

func AnyStateRelease():
	if isMagnetting:
		InvertColliders(false)
		cooldown1 = 0
		Transitioned.emit(self, "AirState")
		isMagnetting = false
		surfaceCheckTimer = 0
		if !isOnMagneticSurface:
			totalFrac = 0
			angle = deg_to_rad(360) - totalAngleRotated
			print("angle: ", rad_to_deg(angle))
			totalFrac = 0
			lastFracEased = 0
			rotateTimer = 0
			playerObj.doCheckIfNoLongerOnFloor = false

func Deactivate():
	reticle.modulate = Color.from_hsv(0, 0, 1, 1)
	active = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	surfaceCheckTimer += 1
	if active:
#		print("total angle rotated: ", rad_to_deg(totalAngleRotated))
		if !isMagnetting && isOnMagneticSurface && surfaceCheckTimer % 15 == 0:
			var isAboveMagnet = false
			for body in magnetGroundDetector.get_overlapping_bodies():
				if body.is_in_group("Magnetic"):
					isAboveMagnet = true
					break
			
			if !isAboveMagnet:
				playerObj.SetNewBasisAndShit(Vector3(0, 1, 0))
				angle = deg_to_rad(360) - totalAngleRotated
				totalFrac = 0
				lastFracEased = 0
				surfaceCheckTimer = 0
				rotateTimer = 0
				playerObj.doCheckIfNoLongerOnFloor = false
				Transitioned.emit(self, "AirState")
				isOnMagneticSurface = false
		
		
		var castObj = rayCaster.get_collider()
		if castObj != null && castObj.is_in_group("Magnetic"):
			reticle.modulate = Color.from_hsv(0, 1, 1, 1)
		else:
			reticle.modulate = Color.from_hsv(0, 0, 1, 1)
	
	rotateTimer += delta
	var x = clamp(1.5 * rotateTimer, 0, 1)
	var amount = 1 - pow(1 - x, 4)
	var funney = angle * (amount - lastFracEased)
	lastFracEased = amount
	totalAngleRotated += funney
	print("total angle rotated: ", rad_to_deg(totalAngleRotated))
#	print("total angle: ", rad_to_deg(totalAngleRotated), " / rotateTimer: ", rotateTimer, " / amount: ", amount, " / funney: ", rad_to_deg(funney))
#	var amountToRotate = initialRotation * fracMoved
#	totalRotation += amountToRotate
#	angleLeft = max(angleLeft - amountToRotate, 0)

	upDirController.rotate(playerObj.get_global_transform().basis.x, funney)
