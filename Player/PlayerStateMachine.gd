extends Node

@export var initial_state : State
@onready var playerObj = $".."

var current_state : State
var previous_state : State
var states : Dictionary = {}

@export var animPlayer : AnimationPlayer

var currState # For any weapons, enemy attacks, and the like that are context-sensitive in terms of state.

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			print("added state: ", child.name.to_lower())
			child.Transitioned.connect(_on_child_transition)
	
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.timer += delta
		current_state.Update(delta)
		current_state.CameraShit()
		if playerObj.updateSpeed:
			playerObj.lastRealVelocity = playerObj.get_real_velocity()
			playerObj.lastVelocity = playerObj.velocity
			if playerObj.is_on_floor():
				playerObj.lastFloorNormal = playerObj.get_floor_normal()
		playerObj.currFloorNormal = playerObj.get_floor_normal()
	
	

#func _physics_process(delta):
	#if current_state:
		#current_state.Physics_Update(delta)

func _on_child_transition(state, new_state_name):
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		previous_state = current_state
		current_state.Exit()
	
	new_state.timer = 0
	new_state.SetCamPosition()
	new_state.Enter()
	current_state = new_state
