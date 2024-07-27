extends Node3D

## This IK Target lags behind the Step Target and is the node that the IK moves
## the bones to touch

@export var step_target: Node3D # The node that is moved by the RayCast
@export var distance_to_take_step: float = 0.15
@export var time_to_take_step_secs: float = 0.05
@export var adjacent_ik_target: Node3D # Adjacent IK Target, of the other legs
@export var snap_distance: float = 2.0 # Snap foot to step target if too far from step target

var is_stepping: bool = false

func _ready():
	top_level = true


func _process(_delta):
	var dist_to_step_target: float = abs(global_position.distance_to(step_target.global_position))
	# Snap to the step target so our legs aren't flying behind us if moving fast
	if dist_to_step_target > snap_distance:
		#print("Dist to step target: ", dist_to_step_target)
		snap_step()
	
	if !is_stepping and dist_to_step_target > distance_to_take_step:
		# Don't step if the adjacent leg is already stepping
		if adjacent_ik_target != null:
			if adjacent_ik_target.is_stepping:
				return
		step()


func step():
	is_stepping = true
	step_tween(time_to_take_step_secs)


func snap_step():
	if adjacent_ik_target != null:
		if adjacent_ik_target.is_stepping:
			return
	
	#print("Snap stepping")
	
	#global_position = step_target.global_position
	step_tween(time_to_take_step_secs / 5)


func step_tween(steptime: float):
	var target_pos = step_target.global_position
	var half_way = (global_position + step_target.global_position) / 2.0
	var t = get_tree().create_tween()
	t.tween_property(self, "global_position", half_way + (owner.basis.y / 10), steptime / 2)
	t.tween_property(self, "global_position", target_pos, steptime / 2)
	t.tween_callback(func(): is_stepping = false)
