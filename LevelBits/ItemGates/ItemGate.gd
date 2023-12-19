extends Node3D

@export var Area : Area3D
@export var ItemNumber : int
@export var AddWeapon : bool

func _ready():
	Area.body_entered.connect(GiveItem)

func GiveItem(player):
	print("boing")
	if AddWeapon:
		player.weaponMan.AddWeapon(ItemNumber)
	else:
		player.weaponMan.RemoveWeapon(ItemNumber)
