extends CharacterBody3D

@export var moveSpeed = 5.0
@export var jumpVel = 4.5
@export var sensitivity = 0.01

var time = 0
var direction : Vector3
var mouseIsHidden = true
var input_dir : Vector2
var lastRealVelocity : Vector3
var gravityActive = true

@onready var neck = $Neck;
@onready var camera = $Neck/Camera3D
@onready var textLabel = $Neck/Camera3D/RichTextLabel
@onready var stateMachine = $MovementStateMachine

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	floor_max_angle = deg_to_rad(89)
	floor_snap_length = 2

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		neck.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _process(delta):
	textLabel.text = "hey buckaroo you are moving this fast: " + str(velocity.length()) + "\nand current state: " + str(stateMachine.current_state)
	
	if Input.is_action_just_pressed("ui_cancel"):
		if mouseIsHidden:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouseIsHidden = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouseIsHidden = true
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	if Input.is_action_pressed("slide") && is_on_floor():
		camera.position.y = -0.7
	else:
		camera.position.y = 0
	
	camera.fov = clamp(75 + 0.1 * velocity.length() * (1 - clamp(velocity.angle_to(-camera.get_global_transform().basis.z) / deg_to_rad(90), 0, 1)), 75, 100)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() && gravityActive:
		velocity.y -= gravity * delta
	
	#print("velocity n shit: ", velocity.length())
	
	if is_on_floor():
		lastRealVelocity = get_real_velocity()
	input_dir = Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBack")
	direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
