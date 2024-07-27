class_name StateMachine
extends Node
# Guided by https://www.youtube.com/watch?v=j_pM3CiQwts&t=124s

## Base Class for State Machines
##
## This Node's children will be States

signal state_changed(state_str: String)

var state: State = null : set = set_state
var previous_state: State = null
var states = {} # Dictionary of States


func _ready():
	pass


func _physics_process(delta):
	if state != null:
		_state_logic(delta)
		var transition: State = _get_transition(delta)
		if transition != null:
			set_state(transition)


func _state_logic(_delta):
	pass # virtual abstract funcion to be overridden in base class


func _get_transition(_delta) -> State:
	return null


func _enter_state(_new_state, _previous_state):
	pass


func _exit_state(_old_state, _new_state):
	pass


func set_state(new_state: State):
	previous_state = state
	state = new_state
	
	if previous_state != null:
		_exit_state(previous_state, new_state)
	if state != null:
		_enter_state(new_state, previous_state)


func add_state(state_name: String, new_state: State):
	states[state_name] = new_state


func get_state_name() -> String:
	if states.is_empty() || state == null:
		return "NA"
	return states.keys()[state]
