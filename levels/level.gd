class_name Level
extends Node3D

@onready var npcs: Node = $NPCs
@onready var spawn_points: Node = $SpawnPoints
@onready var teleport_area: Area3D = $TeleportArea

const COLLISION_CHECKER = preload("res://components/utils/collision_checker.tscn")
var collision_checker: Area3D

func _ready():
	collision_checker = COLLISION_CHECKER.instantiate()
	add_child(collision_checker)
	
	teleport_area.body_entered.connect(on_teleport_area_entered)


# Recursively check each spawnpoint until finding a spot with no overlapping mobs
func place_at_spawn_point(n: Node3D):
	var spot: Node3D = spawn_points.get_children().pick_random()
	print("Got random spot: ", spot.global_position)
	#collision_checker.global_position = spot.global_position
	#await get_tree().create_timer(0.2).timeout
	#for body in collision_checker.get_overlapping_bodies():
		#print("Checking for respawn collisions with ", body, " at spot ", spot.global_position)
		#if body is Mob:
			## Try again
			#place_at_spawn_point(n)
			#return
	n.global_position = spot.global_position
	n.global_rotation = spot.global_rotation
	print("Spawned node ", n.name, " at spot: ", spot.global_position)


func respawn_entity(ent: Node3D):
	place_at_spawn_point(ent)


func on_teleport_area_entered(body: Node3D):
	if body.get_multiplayer_authority() != get_multiplayer_authority():
		return
	respawn_entity(body)
