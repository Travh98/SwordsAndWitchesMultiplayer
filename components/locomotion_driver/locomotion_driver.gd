class_name LocomotionDriver
extends Node

## This class' only purpose is to move the Mob to a position
## Use the public methods to set_target

enum StopDistances {
	STOP_PROXIMITY,
	STOP_EXACT
}

## Exports
@export var ai_controlled: bool = true # If false then controlled by Player
@export var walking_speed: float = 5.0
@export var sprinting_speed: float = 8.0
@export var crouching_speed: float = 3.0
@export var jump_velocity = 4.5

## Movement Settings variables
var gravity_multiplier: float = 1.0
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity: float = (ProjectSettings.get_setting("physics/3d/default_gravity") 
		* gravity_multiplier)
var acceleration: float = 8
var deceleration: float = 10
var air_control: float = 0.6
var jump_height: float= 10
var angular_speed: float= 8.0
var lerp_speed: float = 10.0
var update_diff: float = 0.25 # Update nav path distance

var stop_dist_proximity: float = 2.0 	# Stop moving when comfortably close to target
var stop_dist_exact: float = 0.2 		# Stop moving when almost right on target
var stop_behavior: StopDistances = StopDistances.STOP_PROXIMITY

## Runtime variables, frequently updated
var target_position: Vector3 : set = set_target_pos # The global position to move to
var target_node: Node3D : set = set_target_node
var do_go_to_node: bool = false
var direction: Vector3 # The direction to move in
var current_speed: float = walking_speed

## Components
@onready var mob: CharacterBody3D = get_parent()
@onready var nav_agent: NavigationAgent3D = $"../NavigationAgent3D"
@onready var step_checker: StepChecker = $"../StepChecker"


func _ready():
	current_speed = walking_speed
	if ai_controlled:
		if nav_agent == null or step_checker == null or mob == null:
			push_error("AI LocomotionDriver is missing a dependency, removing")
			queue_free()
	
	nav_agent.velocity_computed.connect(on_safe_velocity_computed)


func _physics_process(delta):
	if !ai_controlled:
		return
	
	# Add the gravity
	if not apply_step(delta):
		if not mob.is_on_floor():
			apply_gravity(delta)
	
	if !get_should_move():
		return
	
	if do_go_to_node:
		try_update_nav_path()
	
	direction = mob.global_position.direction_to(nav_agent.get_next_path_position())
	
	
	if nav_agent.avoidance_enabled:
		# Apply Accelerate, but set the nav_agent's target velocity instead
		var target_velocity: Vector3 = mob.velocity
		target_velocity.x = lerp(target_velocity.x, direction.x * current_speed, delta * lerp_speed)
		target_velocity.z = lerp(target_velocity.z, direction.z * current_speed, delta * lerp_speed)
		nav_agent.set_velocity(target_velocity)
	else:
		apply_accelerate(delta)
		mob.move_and_slide()


func on_safe_velocity_computed(safe_velocity: Vector3) -> void:
	mob.velocity = safe_velocity
	# Hard set gravity, the bad way (without delta)
	if not mob.is_on_floor():
		apply_gravity(0.1)
	mob.move_and_slide()


## Set the node to move to
func set_target_node(follow_node: Node3D):
	target_node = follow_node
	do_go_to_node = true
	try_update_nav_path()


## Set the position to move to
func set_target_pos(destination_position: Vector3):
	target_position = destination_position
	do_go_to_node = false
	try_update_nav_path()


## Clear the nav targets and stop
func clear_target():
	target_position = mob.global_position
	target_node = null
	do_go_to_node = false


func get_is_close_to_target() -> bool:
	if do_go_to_node:
		if target_node == null:
			return true
	
	match stop_behavior:
		StopDistances.STOP_PROXIMITY:
			if do_go_to_node:
				if mob.global_position.distance_to(target_node.global_position) <= stop_dist_proximity:
					return true
				pass
			else:
				if mob.global_position.distance_to(target_position) <= stop_dist_proximity:
					return true
				pass
		StopDistances.STOP_EXACT:
			if do_go_to_node:
				if mob.global_position.distance_to(target_node.global_position) <= stop_dist_exact:
					return true
				pass
			else:
				if mob.global_position.distance_to(target_position) <= stop_dist_exact:
					return true
				pass
	return false


## Returns false if we should stop moving
func get_should_move() -> bool:
	return !get_is_close_to_target()


func try_update_nav_path():
	if target_position.distance_to(nav_agent.target_position) > update_diff:
		nav_agent.target_position = target_position
		#print("Setting new target position: ", target_position, " for mob: ", mob.name)


func apply_accelerate(delta: float) -> void:
	# Make sure direction is normalized
	direction = direction.normalized()
	# Smoothly move in the direction
	mob.velocity.x = lerp(mob.velocity.x, direction.x * current_speed, delta * lerp_speed)
	mob.velocity.z = lerp(mob.velocity.z, direction.z * current_speed, delta * lerp_speed)


func apply_gravity(delta: float):
	mob.velocity.y -= gravity * delta


func apply_jump():
	mob.velocity.y = jump_height


## A legacy StepChecker function
func apply_step(delta: float) -> bool:
	if step_checker == null:
		return false
	
	# Get the position we want to step to
	var step_to_pos: Vector3 = step_checker.can_step(direction, mob.velocity, delta)
	var desired_y_pos: float = 0.0
	# If there is a valid step to position
	if step_to_pos != Vector3.ZERO:
		# Get the distance from our origin to the desired y pos
		desired_y_pos = step_to_pos.y - mob.global_position.y
		
		# Need extra boost to get over steps if moving fast
		if mob.velocity.length() > step_checker.expected_max_speed:
			# If stepping up but the step is smaller than the height we expect steps to be
			if desired_y_pos > 0 and desired_y_pos < step_checker.step_height:
				# Setting desired height to be higher than the step, so its easy to clear the steps when stepping
				desired_y_pos = step_checker.step_height 
				# TODO do we really need step_height if we have the wall_check?
	
	# If we need to step downwards
	if desired_y_pos <= 0:
		# We will descend using gravity
		return false
	else:
		# We need to step upwards
		# Hard set the mob's y velocity
		var target_y_vel: float = desired_y_pos * current_speed * 3
		mob.velocity.y = lerp(mob.velocity.y, target_y_vel, delta * lerp_speed)
		# Return true if we have stepped
		return true
