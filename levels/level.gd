class_name Level
extends Node3D

@export var respawn_pos: LocationIndicator
@onready var spawn_locations = $SpawnLocations
var player: FpsCharacter

const COLLISION_CHECKER = preload("res://components/utils/collision_checker.tscn")
var collision_checker: Area3D

func _ready():
	collision_checker = COLLISION_CHECKER.instantiate()
	add_child(collision_checker)
	
	var all_nodes = []
	GameMgr.GetAllTreeNodes(self, all_nodes)
	for node in all_nodes:
		if node is FpsCharacter:
			player = node


func _input(_event):
	if Input.is_action_just_pressed("restart_scene"):
		if weakref(player).get_ref():
			player.global_position = respawn_pos.global_position
			player.global_rotation = respawn_pos.global_rotation
			player.velocity = Vector3.ZERO


# Recursively check each spawnpoint until finding a spot with no overlapping mobs
func place_at_spawn_point(n: Node3D):
	var spot: Node3D = spawn_locations.get_children().pick_random()
	collision_checker.global_position = spot.global_position
	await get_tree().create_timer(0.2).timeout
	for body in collision_checker.get_overlapping_bodies():
		if body is Mob:
			# Try again
			place_at_spawn_point(n)
			return
	n.global_position = spot.global_position
	n.global_rotation = spot.global_rotation
	print("Spawned node ", n.name, " at spot: ", spot.name)
