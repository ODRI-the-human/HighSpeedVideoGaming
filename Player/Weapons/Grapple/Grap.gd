extends Weapon
class_name Grap

@onready var rayCaster = $"../../Neck/Camera3D/RayCast3D"
@onready var ropeMesh = $"../../Neck/Camera3D/firstPersonHands/metarig/Skeleton3D/BoneAttachment3D/grappleRope"
@onready var reticle = $"../../Neck/Camera3D/Sprite3D"
@export var skeleton : Skeleton3D
var objToGrap
var grapPos
var isGrappling : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	ropeMesh.visible = false
	isGrappling = false

func Attack():
	var castObj = rayCaster.get_collider()
	if castObj != null:
		if castObj.is_in_group("Grapplable"):
			playerObj.stateMachine.animPlayer.play("grapThrow")

func TransitionToGrap():
	grapPos = rayCaster.get_collision_point()
	Transitioned.emit(self, "GrapRetractState")
	isGrappling = true
	print("gobule")

func Alt():
	if isGrappling && cooldown1 <= 0:
		playerObj.stateMachine.animPlayer.play("grapYank")
		Transitioned.emit(self, "GrapYankState")
		isGrappling = false

func Release():
	if isGrappling:
		cooldown1 = 0
		Transitioned.emit(self, "AirState")
		ropeMesh.visible = false
		isGrappling = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isGrappling:
		timer += delta
		if timer > 0.1:
			ropeMesh.visible = true
		else:
			ropeMesh.visible = false
		ropeMesh.look_at(grapPos)
		ropeMesh.scale = Vector3(1, 1, (ropeMesh.global_position - grapPos).length() / 2)
	else:
		ropeMesh.visible = false
		timer = 0
	
	var castObj = rayCaster.get_collider()
	if active:
		if castObj != null && castObj.is_in_group("Grapplable"):
			reticle.modulate = Color.from_hsv(0, 1, 1, 1)
		else:
			reticle.modulate = Color.from_hsv(0, 0, 1, 1)
		
