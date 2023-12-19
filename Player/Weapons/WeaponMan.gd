extends Node

@export var rayCaster : RayCast3D
@onready var bottomCollider = $"../.."
@export var reticle : Node3D

@onready var grap = $"../Grap"
@onready var magnet = $"../Magnet"

var weaponsHeld = []

var activeWeaponNode : Node
var activeWeaponID : int
var newWeapon : int

func _ready():
	rayCaster.add_exception(bottomCollider)
	SetActiveWeapon(-1)

func AddWeapon(weapon):
	if !weaponsHeld.has(weapon):
		weaponsHeld.append(weapon)
	SetActiveWeapon(weapon)
	print("now this is epic you picked up a weapon, ID: ", weapon)

func RemoveWeapon(weapon):
	if weaponsHeld.has(weapon):
		weaponsHeld.erase(weapon)
		GetWeaponFromID(weapon).Deactivate()
	
	if weapon == activeWeaponID:
		if weaponsHeld.size() > 0:
			SetActiveWeapon(weaponsHeld[0])
		else:
			SetActiveWeapon(-1)

func GetWeaponFromID(ID : int):
	var weapon : Node
	match ID:
		-1:
			weapon = null
		0:
			weapon = grap
		1:
			weapon = magnet
	return weapon

func SetActiveWeapon(weapon : int):
	activeWeaponID = weapon
	activeWeaponNode = GetWeaponFromID(weapon)
	for heldWeapon in weaponsHeld:
		if heldWeapon == activeWeaponID:
			GetWeaponFromID(heldWeapon).active = true
		else:
			GetWeaponFromID(heldWeapon).Deactivate()

func SwitchWeapons(dir : int):
	newWeapon = weaponsHeld.find(activeWeaponID) + dir
	if newWeapon > weaponsHeld.size() - 1:
		newWeapon = 0
	elif newWeapon < 0:
		newWeapon = weaponsHeld.size() - 1
	
	SetActiveWeapon(weaponsHeld[newWeapon])

# Called when the node enters the scene tree for the first time.
func _process(delta):
	# for switching weapons.
	if Input.is_action_just_pressed("WeaponScrollUp"):
		SwitchWeapons(1)
	elif Input.is_action_just_pressed("WeaponScrollDown"):
		SwitchWeapons(-1)
	
	if activeWeaponID != -1:
		if Input.is_action_just_pressed("attack"):
			activeWeaponNode.Attack()
		if Input.is_action_just_released("attack"):
			activeWeaponNode.Release()
		
		if Input.is_action_just_pressed("alt"):
			activeWeaponNode.Alt()
		if Input.is_action_just_released("alt"):
			activeWeaponNode.AltRelease()
