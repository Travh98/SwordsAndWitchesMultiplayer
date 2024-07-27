class_name Level
extends Node3D

@export var respawn_pos: LocationIndicator
@onready var spawn_locations = $SpawnLocations
@onready var npc_respawn_spot = $KnightRespawnSpot
@onready var blue_respawn_spot = $KnightRespawnSpot2
@onready var teleport_area: Area3D = $TeleportArea

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
	
	teleport_area.body_entered.connect(on_teleport_area_entered)


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


func on_teleport_area_entered(body: Node3D):
	
	if body is Mob:
		body.velocity = Vector3.ZERO
		if body.faction == FactionMgr.Factions.RED:
			body.global_position = npc_respawn_spot.global_position
			return
	body.global_position = blue_respawn_spot.global_position
