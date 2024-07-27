class_name MoveToPosState
extends State

## State for Following something else
##
## The state machine will set which node to follow

# Components this state needs
var mob: Mob
var target_pos: Vector3
@onready var nav_agent: NavigationAgent3D = $"../../NavigationAgent3D"

# True if within stopping distance
var in_stopping_distance: bool = false
# Variables for this state
@export var stop_distance: float = 1.5
# Recalculate the navigation to the target if the target is this far from the current nav destination
@export var recalc_nav_dist: float = 0.5


func _enter_state():
	pass


func _state_logic(delta: float):
	if(target_pos.distance_to(nav_agent.target_position) > recalc_nav_dist):
		nav_agent.target_position = target_pos
	
	var dist_to_target: float = mob.global_position.distance_to(target_pos)
	if dist_to_target > stop_distance:
		in_stopping_distance = false
		mob.direction = mob.global_position.direction_to(nav_agent.get_next_path_position()).normalized()
		mob.rotate_towards_position(target_pos, delta)
	else:
		in_stopping_distance = true
		mob.direction = Vector3.ZERO


func _exit_state():
	pass
