extends Node

@export var initial_state : State
@onready var playerObj = $".."

var current_state : State
var states : Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(_on_child_transition)
	
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.Update(delta)
		if playerObj.updateSpeed:
			playerObj.lastRealVelocity = playerObj.get_real_velocity()
			playerObj.lastVelocity = playerObj.velocity

#func _physics_process(delta):
	#if current_state:
		#current_state.Physics_Update(delta)

func _on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.Exit()
	
	new_state.Enter()
	
	current_state = new_state
