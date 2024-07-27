class_name State
extends Node

## Virtual base class for all StateMachine states

func _state_logic(_delta: float):
	pass # virtual abstract funcion to be overridden in base class


func _enter_state():
	pass


func _exit_state():
	pass
