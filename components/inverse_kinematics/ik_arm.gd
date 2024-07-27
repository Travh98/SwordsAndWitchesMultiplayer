class_name IkArm
extends Node3D

@export var skele_ik: SkeletonIK3D
@export var default_target: Node3D
var target: Node3D

func _ready():
	skele_ik.start()
	pass


func set_ik_target(n: Node3D):
	if n == null:
		skele_ik.target_node = default_target.get_path()
	else:
		skele_ik.target_node = n.get_path()
	#print("Set target to: ", n)
