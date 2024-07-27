extends Node3D

@export var eject_force: float = 5
@export var angular_force: float = 50
@export var despawn_time_secs: float = 10

const BULLET_CASING_RB = preload("res://components/muzzle_flashes/bullet_casing_rb.tscn") 

func on_fire():
	var casing: RigidBody3D = BULLET_CASING_RB.instantiate()
	get_tree().root.add_child(casing)
	casing.global_position = global_position
	casing.global_rotation = global_rotation
	
	casing.linear_velocity = Vector3.FORWARD * randf_range(eject_force - eject_force / 2, eject_force) + Vector3.RIGHT * randf_range(-eject_force / 4, eject_force / 4)
	casing.angular_velocity = Vector3.RIGHT * randf_range(-angular_force, angular_force)
	
	await get_tree().create_timer(despawn_time_secs).timeout
	casing.queue_free()
	
