class_name PauseState
extends State

# Components this state needs
@onready var mob: Mob
@onready var nav_agent: NavigationAgent3D = $"../../NavigationAgent3D"
@onready var timeout_timer: Timer = $TimeoutTimer

# Variables for this state
@export var timeout_time: float = 2.0


func _ready():
	timeout_timer.wait_time = timeout_time
	timeout_timer.one_shot = true


func _enter_state():
	timeout_timer.start()
	
	if weakref(mob).get_ref():
		mob.direction = Vector3.ZERO


func _state_logic(_delta: float):
	pass


func _exit_state():
	pass



