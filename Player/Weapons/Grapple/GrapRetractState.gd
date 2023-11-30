extends State
class_name GrapRetractState

var grapPos
@onready var grapMain = $"../Grap"
var lastPosition
var lastDot
var isRetracting

func Enter():
	#if !grapMain.isGrappling:
		#playerObj.stateMachine.animPlayer.play("grapThrow")
	print("Entered grap retract state")
	grapPos = grapMain.grapPos
	playerObj.gravityActive = true
	var deltaVec = (grapPos - playerObj.position)
	lastDot = deltaVec.dot(playerObj.velocity)
	lastPosition = playerObj.position
	isRetracting = true

func Update(delta):
	playerObj.velocity -= 1.25 * playerObj.velocity.normalized() * delta
	#playerObj.velocity += 40 * (grapPos - playerObj.position).normalized() * delta
	
	# velDot is the dot product of the delta between the grappos and velocity; if < 0 the player is
	# moving away from the grap position, if > 0 they're moving towards it!
	var deltaVec = (grapPos - playerObj.position)
	var velDot = deltaVec.dot(playerObj.velocity)
	
	var currDist = (grapPos - playerObj.position).length()
	var crossProd = deltaVec.normalized().cross(playerObj.velocity.normalized())
	#print("dot of player to grap / velocity: ", velDot)
	#playerObj.velocity += -(playerObj.position - grapPos).normalized() * pow(playerObj.velocity.length(),2) / (playerObj.position - grapPos).length() * delta
	#playerObj.move_and_slide()
	
	if velDot * lastDot < 0:
		#print("stater's change, velDot: ", velDot, " / lastDot: ", lastDot, " / deltaVec length: ", deltaVec.length())
		if velDot < 0:
			print("erm that just happened, now circling...")
			isRetracting = false
		else:
			print("retractified...")
			isRetracting = true
	
	if isRetracting: #if (playerObj.position - grapPos).length() > maxDist:
		#if deltaVec.length() > 7.5:
		playerObj.velocity += 17 * deltaVec.normalized() * delta * clamp(pow(deltaVec.length(), 1.15) / 120, 0.75, 2.5)
		#print("retract")
	else:
		#playerObj.velocity = (playerObj.velocity + 0.5 * deltaVec * delta * playerObj.velocity.length()).normalized() * playerObj.velocity.length()
		# newVector is the player's next position after this update.
		var newVector = playerObj.velocity * delta + playerObj.position
		var lengthOverMaxLength = (grapPos - newVector).length() - deltaVec.length()
		newVector += 2 * lengthOverMaxLength * deltaVec.normalized()
		playerObj.velocity = (newVector - lastPosition).normalized() * playerObj.velocity.length()
		#print("delter vecting: ", deltaVec.length())
		#playerObj.velocity = deltaVec.normalized().rotated(crossProd, deg_to_rad(90)) * playerObj.velocity.length()
		#	playerObj.velocity = lastVelocity
		#print("swing")

	#if lastVelocity.dot(playerObj.velocity) < 0.2:
	#	print("game's shit")
	#print("vel: ", round(playerObj.velocity * 100) / 100, " / delt: ", round(deltaVec * 100) / 100, " / deltL: ", round(deltaVec.length() * 100) / 100, " / dot: ", round(velDot * 100) / 100, " / cross: ", round(crossProd * 100) / 100)

	#if lastVelocity.dot(playerObj.velocity) < 0.2:
	#	print("game's shit")
	
	#playerObj.velocity.y -= playerObj.gravity * delta
	
	lastPosition = playerObj.position
	lastDot = velDot
	playerObj.move_and_slide()
