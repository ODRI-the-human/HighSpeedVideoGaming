extends State
class_name GrapRetractState

var grapPos
@onready var grapMain = $"../Grap"

func Enter():
	if !grapMain.isGrappling:
		playerObj.stateMachine.animPlayer.play("khopeshParry")
	print("Entered grap retract state")
	grapPos = grapMain.grapPos
	playerObj.gravityActive = true

func Update(delta):
	playerObj.velocity -= 5 * playerObj.velocity.normalized() * delta
	playerObj.velocity += 40 * (grapPos - playerObj.position).normalized() * delta
	playerObj.updateSpeed = true
	playerObj.move_and_slide()
