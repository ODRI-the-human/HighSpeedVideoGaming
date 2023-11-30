extends State
class_name GrapYankState

var grapPos
var lastSpeed
var newDirFac = 0.7
@onready var grapMain = $"../Grap"

func Enter():
	#playerObj.stateMachine.animPlayer.play("grapYank")
	grapPos = grapMain.grapPos
	playerObj.gravityActive = true
	lastSpeed = clamp(playerObj.lastVelocity.length(), 30, INF)
	playerObj.velocity = (playerObj.velocity.normalized() * (1 - newDirFac) + (grapPos - playerObj.position).normalized() * newDirFac).normalized() * lastSpeed
	playerObj.updateSpeed = true
	print("Entered grap yank state, lastSpeed: ", lastSpeed, " / current speed: ", playerObj.lastVelocity.length())

func Update(delta):
	Transitioned.emit(self, "AirState")
