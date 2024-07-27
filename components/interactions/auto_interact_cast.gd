class_name AutoInteractCast
extends RayCast3D

signal do_interact()

@export var interact_range: float = 2.0

var target: Node3D


func _process(delta):
	if target:
		target_position = Vector3.ZERO.direction_to(to_local(target.global_position)).normalized() * interact_range



func _physics_process(delta):
	if target:
		if is_colliding():
			if get_collider() == target.get_node("InteractArea"):
				do_interact.emit()
				#print("Do auto interact")
