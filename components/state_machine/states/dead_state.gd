class_name DeadState
extends State

## State for Wandering around in a random direction
##
## When a mob dies, stop moving

# Components this state needs
var mob: Mob
@onready var nav_agent: NavigationAgent3D = $"../../NavigationAgent3D"


func _ready():
	pass


func _enter_state():
	mob.direction = Vector3.ZERO
	nav_agent.target_position = mob.global_position


func _state_logic(_delta: float):
	pass


func _exit_state():
	pass
