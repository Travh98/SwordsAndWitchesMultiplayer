extends Node
class_name MobBrain

## This is a Test class to see how we can think for a Mob and control the other nodes
## This might vary for each mob
## They should all have the same base variables though, like who we are attacking/following, what is our state

@onready var mob: Mob = get_parent()
@onready var locomotion_driver: LocomotionDriver = $"../LocomotionDriver"
@onready var locomotion_anim_driver: LocomotionAnimDriver = $"../LocomotionDriver/LocomotionAnimDriver"
@onready var detection_area: DetectionArea = $"../DetectionArea"
@onready var rescan_timer: Timer = $RescanTimer

var friendly_target: Mob
var follow_stop_dist: float = 3.0


func _ready():
	if locomotion_driver == null:
		push_warning("No Locomotion Driver for ", mob.name)
	
	rescan_timer.timeout.connect(on_rescan)


func _physics_process(_delta):
	if friendly_target == null:
		friendly_target = detection_area.scan_for_living_target()
	else:
		var dist_to_target: float = locomotion_driver.target_position.distance_to(friendly_target.global_position)
		if dist_to_target > locomotion_driver.update_diff:
			locomotion_driver.set_target_pos(get_follow_destination(friendly_target))
		if dist_to_target > 5.0:
			locomotion_anim_driver.set_facing_mode(LocomotionAnimDriver.FacingDirection.FACE_MOTION)
		else:
			locomotion_anim_driver.set_facing_mode(LocomotionAnimDriver.FacingDirection.FACE_TARGET)


func get_follow_destination(target: Mob) -> Vector3:
	return target.global_position + target.global_position.direction_to(mob.global_position).normalized() * follow_stop_dist 


func on_rescan():
	friendly_target = detection_area.scan_for_living_target()
