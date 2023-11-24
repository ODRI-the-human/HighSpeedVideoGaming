extends State
class_name GrapYankState

var grapPos
var lastSpeed
var newDirFac = 0.7
@onready var grapMain = $"../Grap"

func Enter():
	playerObj.stateMachine.animPlayer.play("khopeshSwing")
	print("Entered grap yank state")
	grapPos = grapMain.grapPos
	playerObj.gravityActive = true
	lastSpeed = clamp(playerObj.lastVelocity.length(), 30, INF)
	playerObj.velocity = (playerObj.velocity.normalized() * (1 - newDirFac) + (grapPos - playerObj.position).normalized() * newDirFac) * lastSpeed
	playerObj.updateSpeed = true

func Update(delta):
	playerObj.move_and_slide()
	Transitioned.emit(self, "GrapRetractState")
