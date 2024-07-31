class_name RagdollMgr
extends Node

## Manages a ragdoll spawned after entity death

const KNIGHT_RAGDOLL = preload("res://assets/characters/knight_ragdoll.tscn")
var ragdoll: Node3D

func spawn_ragdoll():
	despawn_ragdoll()
	
	ragdoll = KNIGHT_RAGDOLL.instantiate()
	add_child(ragdoll)
	ragdoll.global_position = get_parent().global_position
	ragdoll.start_ragdoll()


func despawn_ragdoll():
	if ragdoll != null:
		ragdoll.queue_free()
