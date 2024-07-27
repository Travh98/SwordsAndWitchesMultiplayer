class_name WanderState
extends State

## State for Wandering around in a random direction
##
## Find a spot to wander to
## If we get close enough to that spot, we are satisfied
## Else if our timeout timer goes off, we are satisfied

# TODO: (Travh98) The mob will jiggle when it cannot reach the target spot
# The fix for this is to ensure that the random point is on the NavMesh

# Components this state needs
var mob: Mob
@onready var nav_agent: NavigationAgent3D = $"../../NavigationAgent3D"
@onready var wander_timer: Timer = $WanderTimer

# Variables for this state
var wander_target: Vector3
@export var wander_timeout_time: float = 2.0
@export var wander_stop_distance: float = 1.0
@export var wander_max_distance: float = 5.0
@export var wander_min_distance: float = 2.0

# If satisfied, then we are done wandering. This is a flag for letting the StateMachine know
var is_satisfied: bool = false : set = set_is_satisfied


func _ready():
	wander_timer.wait_time = wander_timeout_time
	wander_timer.one_shot = true
	wander_timer.timeout.connect(on_timeout)


func _enter_state():
	set_is_satisfied(false)
	wander_timer.start()
	
	# Get a random x and z around the mob
	var wander_x_relative: float = randf_range(wander_min_distance, wander_max_distance)
	if randi_range(0, 1) == 1:
		wander_x_relative = -wander_x_relative
	var wander_z_relative: float = randf_range(wander_min_distance, wander_max_distance)
	if randi_range(0, 1) == 1:
		wander_z_relative = -wander_z_relative
	
	# Set the wander target position
	wander_target = mob.global_position + Vector3(wander_x_relative, 
		0, 
		wander_z_relative)
	nav_agent.target_position = wander_target


func _state_logic(delta: float):
	if is_satisfied:
		return
	
	var dist_to_target: float = mob.global_position.distance_to(nav_agent.target_position)
	if dist_to_target > wander_stop_distance:
		mob.direction = mob.global_position.direction_to(nav_agent.get_next_path_position()).normalized()
		mob.rotate_towards_motion_no_y(delta)
	else:
		set_is_satisfied(true)


func _exit_state():
	pass


func on_timeout():
	set_is_satisfied(true)


func set_is_satisfied(satisfied: bool):
	is_satisfied = satisfied
	if satisfied:
		#var dist_to_target: float = mob.global_position.distance_to(nav_agent.target_position)
		#print("Wander state has been satisfied, mob is ", str("%.2f" % dist_to_target), "m from target. ", mob.global_position, " to ", nav_agent.target_position)
		wander_timer.stop()
