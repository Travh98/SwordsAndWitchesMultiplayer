class_name FollowState
extends State

## State for Following something else
##
## The state machine will set which node to follow

# Components this state needs
var mob: Mob
var follow_target: Node3D
@onready var nav_agent: NavigationAgent3D = $"../../NavigationAgent3D"

# True if within stopping distance
var in_stopping_distance: bool = false
# Variables for this state
@export var stop_distance: float = 0.25
# Recalculate the navigation to the target if the target is this far from the current nav destination
@export var recalc_nav_dist: float = 1.0


func _enter_state():
	pass


func _state_logic(delta: float):
	if !weakref(follow_target).get_ref():
		print("No follow target!")
		return
	
	if(follow_target.global_position.distance_to(nav_agent.target_position) > recalc_nav_dist):
		nav_agent.target_position = follow_target.global_position
		#print("Recalculating nav path")
	
	var dist_to_target: float = mob.global_position.distance_to(follow_target.global_position)
	if dist_to_target > stop_distance:
		in_stopping_distance = false
		mob.direction = mob.global_position.direction_to(nav_agent.get_next_path_position()).normalized()
		mob.rotate_towards_position(follow_target.position, delta)
		#print("Following target: ", follow_target, " that next nav path pos is ", str("%.2f" % dist_to_target), "m away")
	else:
		#print("Close enough to target: ", str("%.2f" % dist_to_target))
		in_stopping_distance = true
		mob.direction = Vector3.ZERO


func _exit_state():
	pass
