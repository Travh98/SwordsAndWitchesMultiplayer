extends Node
class_name LocomotionAnimDriver

## This class manages rotating the Mob to face a direction
## This node should be a child of LocomotionDriver

@onready var mob: CharacterBody3D = $"../.."
@onready var locomotion_driver: LocomotionDriver = $".."

@export var anim_tree: AnimationTree

enum FacingDirection {
	FACE_STILL,
	FACE_MOTION,
	FACE_TARGET
}
var facing_direction_mode: FacingDirection = FacingDirection.FACE_STILL : set = set_facing_mode


func _physics_process(delta):
	match facing_direction_mode:
		FacingDirection.FACE_STILL:
			# Do nothing
			pass
		FacingDirection.FACE_MOTION:
			rotate_towards_motion_no_y(delta)
			pass
		FacingDirection.FACE_TARGET:
			rotate_towards_position(locomotion_driver.target_position, delta)
			pass
		_:
			pass
	
	if anim_tree != null:
		var relative_move_angle: float = mob.velocity.signed_angle_to(-mob.transform.basis.z, Vector3.UP) + PI/2
		var relative_movement: Vector2 = Vector2(cos(relative_move_angle), sin(relative_move_angle))
		
		# A BlendSpace2D named move_blend for blending between walking and running in all directions
		anim_tree.set("parameters/move_blend/blend_position", relative_movement * mob.velocity.length() / locomotion_driver.walking_speed)


func set_facing_mode(mode: FacingDirection):
	facing_direction_mode = mode


func rotate_towards_motion_no_y(delta: float):
	## Rotate so caller is facing the position
	#var current_direction := -mob.global_transform.basis.z
	## Get the axis to rotate on
	#var axis := Vector3.UP
	## Make sure its not zero
	#if axis == Vector3.ZERO:
		#return
	#var angle := current_direction.signed_angle_to(locomotion_driver.direction, axis)
	#var angle_step: float = min(locomotion_driver.angular_speed * delta, abs(angle)) * sign(angle)
#	rotate(axis, angle_step)
	#mob.rotation.y = lerp(mob.rotation.y, mob.rotation.y + angle_step, locomotion_driver.angular_speed * locomotion_driver.angular_speed * delta)
	mob.rotation.y = lerp_angle(mob.rotation.y, atan2(-locomotion_driver.direction.x, -locomotion_driver.direction.z), delta * locomotion_driver.angular_speed)
#	rotation.y = lerp(rotation.y, abs(angle) * sign(angle), angular_speed * delta)


func rotate_towards_position(target_pos: Vector3, delta: float):
	var current_direction: Vector3 = -mob.global_transform.basis.z
	var target_direction: Vector3 = mob.global_position.direction_to(target_pos)
	
	# Get the axis to rotate on
	var axis := Vector3.UP
	# Make sure its not zero
	if axis == Vector3.ZERO:
		return
	var angle := current_direction.signed_angle_to(target_direction, axis)
	var angle_step: float = min(locomotion_driver.angular_speed * delta, abs(angle)) * sign(angle)
	mob.rotate(axis, angle_step)
