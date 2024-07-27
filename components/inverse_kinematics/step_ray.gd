extends RayCast3D

## Places the step target on the floor front of the IK mob

@onready var step_target: Node3D = $StepTarget

func _physics_process(delta):
	if !step_target:
		return
	# Smoothly move the step target to be on the floor
	var hit_point = get_collision_point()
	if hit_point:
		step_target.global_position = lerp(step_target.global_position, hit_point, 2 * delta)
