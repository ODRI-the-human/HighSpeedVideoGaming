extends Node

@onready var rayCaster = $"../../Neck/Camera3D/RayCast3D"
@onready var bottomCollider = $"../.."
@onready var reticle = $"../../Neck/Camera3D/Sprite3D"

@onready var grap = $"../Grap"

var activeWeapon

func _ready():
	rayCaster.add_exception(bottomCollider)
	activeWeapon = grap
	grap.active = true

# Called when the node enters the scene tree for the first time.
func _process(delta):
	if Input.is_action_just_pressed("attack"):
		activeWeapon.Attack()
	if Input.is_action_just_released("attack"):
		activeWeapon.Release()
	
	if Input.is_action_just_pressed("alt"):
		activeWeapon.Alt()
	if Input.is_action_just_released("alt"):
		activeWeapon.AltRelease()
