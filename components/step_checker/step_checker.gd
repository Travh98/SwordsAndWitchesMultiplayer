class_name StepChecker
extends Node3D

## This node allows CharacterBody3Ds to step over small inclines, climb onto ledges, and sometimes rocket off the map

@onready var wall_check: RayCast3D = $WallCheck
@onready var floor_check: RayCast3D = $FloorCheck
@onready var ceiling_check: RayCast3D = $CeilingCheck

@export var character_height: float = 2.0 
@export var step_height: float = 0.25
@export var radius_to_check_step: float = 0.75
@export var expected_max_speed: float = 8.0 

var parent: Node3D = null


func _ready():
	parent = get_parent()
	wall_check.add_exception(parent)
	floor_check.add_exception(parent)
	wall_check.add_exception(parent)


# Uses raycasts to see if a valid step is in the direction of desired direction
# Returns the relative position to step to, or Vector3.ZERO if no step
func can_step(desired_dir: Vector3, current_velocity: Vector3, _delta: float) -> Vector3:
	# This is a top level object, so move to where it belongs on the character
	# We are top level to avoid inheriting rotations
	global_position = parent.global_position + Vector3(0, character_height / 2 + step_height, 0)
	
	# Wall Check points from the Mob's center towards the direction of movement
	wall_check.position = Vector3.ZERO
	wall_check.target_position = Vector3(desired_dir.normalized().x, 0, desired_dir.normalized().z) * \
		radius_to_check_step * clamp(current_velocity.length() / expected_max_speed, 1.0, 2.0)
	
	# Floor Check points from then end of the Wall Check to the ground
	floor_check.position = wall_check.position + wall_check.target_position
	floor_check.target_position = -Vector3.UP * character_height * 2
	
	# Ceiling Check points from the end of the Wall Check to the ceiling
	ceiling_check.position = wall_check.position + wall_check.target_position
	ceiling_check.target_position = Vector3.UP * character_height * 2
	
	var floor_pos: Vector3 = Vector3.ZERO
	if is_wall_detected():
#		print("Wall is blocking: ", wall_check.get_collider())
		return Vector3.ZERO
	
	if !is_floor_detected():
#		print("No floor to step on")
		return Vector3.ZERO
	else:
		# Global position of where the floor check hits
		floor_pos = floor_check.get_collision_point()
	
	return floor_pos
	
	# Removing ceiling check because it prevents entering doorways with step ups
#	if is_ceiling_detected():
#		var ceiling_pos = ceiling_check.get_collision_point() # Global coords
#
#		# Is there enough room between the floor and ceiling to step to?
#		if ceiling_pos.distance_to(floor_pos) < character_height:
##			print("No room for head")
#			return Vector3.ZERO
#		else:
##			print("Step to floor pos: ", floor_pos)
#			return floor_pos
#	else:
#		print("Step to floor pos: ", floor_pos)
#		return floor_pos


func is_wall_detected() -> bool:
#	wall_check.enabled = true
	wall_check.force_raycast_update()
#	wall_check.enabled = false
	if wall_check.is_colliding():
		return true
	return false


func is_floor_detected() -> bool:
#	floor_check.enabled = true
	floor_check.force_raycast_update()
#	floor_check.enabled = false
	if floor_check.is_colliding():
		return true
	return false


func is_ceiling_detected() -> bool:
#	ceiling_check.enabled = true
	ceiling_check.force_raycast_update()
#	ceiling_check.enabled = false
	if ceiling_check.is_colliding():
		return true
	return false
