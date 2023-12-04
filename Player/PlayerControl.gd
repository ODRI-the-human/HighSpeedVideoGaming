extends CharacterBody3D

@export var jumpVel = 4.5
@export var sensitivity = 0.01

var time = 0
var direction : Vector3
var mouseIsHidden = true
var input_dir : Vector2
var gravityActive = true
var speedState = 0 # 0 for normal speed. When moving at over 30 speed, goes to 1, at over 60 it goes to 2. Needed for some abilities n such
var lastVelocity : Vector3
var lastRealVelocity : Vector3
var currFloorNormal : Vector3
var lastFloorNormal : Vector3
var updateSpeed = true
var wasGrounded = true # used for coyote time, set at the end of the enter of every state. If this is true when 
#                        entering airState, the coyote timer is started.

var canAirPunch = true

@onready var neck = $Neck;
@onready var camera = $Neck/Camera3D
@onready var textLabel = $Neck/Camera3D/RichTextLabel
@onready var stateMachine = $MovementStateMachine
@onready var weaponMan = $MovementStateMachine/WeaponManager

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	floor_max_angle = deg_to_rad(89)
	floor_snap_length = 2
	currFloorNormal = get_floor_normal()

func _input(event):
	if event is InputEventMouseMotion:
		neck.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _process(delta):
	var colObject = weaponMan.rayCaster.get_collider()
	var name = "bajookie"
	if colObject != null:
		name = colObject.to_string()
	
	textLabel.text = "hey buckaroo 'last' velocity: " + str(lastVelocity.length()) + "\nlast velocity components:\n" + str(lastVelocity.x) + "\n" + str(lastVelocity.y) + "\n" + str(lastVelocity.z) + "\nlast real velocity: " + str(lastRealVelocity.length()) + "\nlast real velocity components:\n" + str(lastRealVelocity.x) + "\n" + str(lastRealVelocity.y) + "\n" + str(lastRealVelocity.z) + "\ncurrent state: " + str(stateMachine.current_state) + "\nprevious state: " + str(stateMachine.previous_state) + "\nfloor normal components:\n" + str(lastFloorNormal.x) + "\n" + str(lastFloorNormal.y) + "\n" + str(lastFloorNormal.z) + "\ncurrent state (number): " + str(stateMachine.currState) + "\ncurrent ray cast hit: " + name
	speedState = clamp(floor(lastVelocity.length()/20), 0, 2)
	
	if Input.is_action_just_pressed("ui_cancel"):
		if mouseIsHidden:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouseIsHidden = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouseIsHidden = true
	
	if Input.is_action_just_pressed("DebugSlow"):
		if Engine.time_scale == 0.05:
			Engine.time_scale = 1
		else:
			Engine.time_scale = 0.05
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	camera.fov = clamp(75 + 0.1 * get_real_velocity().length() * (1 - clamp(get_real_velocity().angle_to(-camera.get_global_transform().basis.z) / deg_to_rad(90), 0, 1)), 75, 100)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() && gravityActive:
		velocity.y -= gravity * delta
	
	#print("velocity n shit: ", velocity.length())
	
	input_dir = Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBack")
	direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
