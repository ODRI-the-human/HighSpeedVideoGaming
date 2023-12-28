extends Camera3D

var shakeIntensity : float # for noise-based shake.
var shakeTimer : float
var shakeVec : Vector2 # Stores the randomised shakeVec.
var shakeVecChangeTimer : float
var pushVec : Vector2 # for pushing camera; this vector is continually decreased in magnitude, like the shake fac.
var pushVecFac : float
var FovMod : float # What to multiply the FOV by. 1 by standard (obviously), and tends towards 1 over time after being changed.
var bajooker : float # stores the pushVecFac at the instant the impact occurs.
var FovBajooker : float # Does the same, but for FOV.
var timer : float

@export var playerObj : CharacterBody3D


var debugTimer = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	CreateImpact(Vector3(0, 0, 2), 3, 0.3, 0.3, 0)
#	shakeFac = 0.3
#	pushVec = Vector2(1, 1)
#	pushVecFac = 0.2


func EaseSurgeish():
	var val = timer * exp(-30 *timer)
#	if debugTimer % 5 == 0 && comparer == FovBajooker:
#		print("surge val: ", val)
	return val

func EaseCubic(fac : float):
	return pow(fac * 3, 3)

func LandingImpact():
	var bajooker = clamp(0.25 * playerObj.get_floor_normal().dot(playerObj.lastRealVelocity), -5, 5)
	CreateImpact(playerObj.get_floor_normal(), bajooker * 0.1, bajooker * 0.15, 0.2, 0)

func CreateImpact(direction : Vector3, pushAmount : float, shakeAmount: float, shakeTime: float, hitLagTime : float): # automatically sets FOV mod, push and shake stuff.
	# direction is the vector from the thing to make impact for
	# pushAmount is the amount to push the camera; factors into both pushVec and FovMod
	# pushTime is the time (in seconds) for the push to decay.
	# shakeAmount is the amount/duration of noise-based shake.
	FovMod = direction.normalized().dot(get_global_transform().basis.z.normalized()) * pushAmount * 0.4
	pushVec = clamp(Vector2(-direction.dot(get_global_transform().basis.x), -direction.dot(get_global_transform().basis.y)), Vector2(-1, -1), Vector2(1, 1))
	shakeIntensity = 0.03 * shakeAmount / shakeTime
	shakeTimer = shakeTime
	pushVecFac = abs(pushAmount) * 3
	timer = 0
	shakeVecChangeTimer = 0
#	print("funny. Direction: ", round(direction * 100) / 100, " / Camera forward: ", round(get_global_transform().basis.z * 100) / 100, " / FovMod: ", round(FovMod * 100) / 100, " / pushVec: ", round(pushVec * 100) / 100, " / shakeFac: ", round(shakeIntensity * 100) / 100, " / pushVecFac: ", round(pushVecFac * 100) / 100)
	OS.delay_msec(hitLagTime * 1000)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	debugTimer += 1
	fov = clamp(75 + 0.1 * playerObj.get_real_velocity().length() * (1 - clamp(playerObj.get_real_velocity().angle_to(-get_global_transform().basis.z) / deg_to_rad(90), 0, 1)), 75, 100)
	fov += 1000 * FovMod * EaseSurgeish()#EaseSurgeish(abs(FovMod), abs(FovBajooker))
	if shakeVecChangeTimer > 0.05:
		shakeVec = Vector2(randfn(0, 0.04 * shakeIntensity), randfn(0, 0.04 * shakeIntensity))
		shakeVecChangeTimer -= 0.05
	
	h_offset = shakeVec.x * shakeTimer + pushVec.x * EaseSurgeish() * pushVecFac
	v_offset = shakeVec.y * shakeTimer + pushVec.y * EaseSurgeish() * pushVecFac
	
#	h_offset = randfn(0, 0.04 * shakeIntensity) * shakeTimer + pushVec.x * EaseSurgeish()
#	v_offset = randfn(0, 0.04 * shakeIntensity) * shakeTimer + pushVec.y * EaseSurgeish()
#	position = Vector3(shakeFac * randf(), shakeFac * randf(), shakeFac * randf())# + pushVec
#	print("camera position: ", position, " / shakeFac: ", shakeFac)
#	shakeIntensity = max(shakeIntensity - delta, 0)
#	pushVecFac = max(pushVecFac - 0.4 * delta, 0)
#	FovMod = max(pushVecFac - sign(FovMod) * delta, 0)
	timer += delta
	shakeVecChangeTimer += delta
	shakeTimer = max(shakeTimer - delta, 0)
