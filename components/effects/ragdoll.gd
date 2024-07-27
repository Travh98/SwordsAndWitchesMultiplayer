class_name Ragdoll
extends Node

@export var skeleton: Skeleton3D

func _ready():
	if skeleton == null:
		push_warning("No skeleton for Ragdoll: ", name)


func start_ragdoll():
	if skeleton:
		skeleton.physical_bones_start_simulation()
