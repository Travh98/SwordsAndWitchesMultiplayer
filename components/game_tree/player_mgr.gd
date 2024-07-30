class_name PlayerMgr
extends Node

## Manages player characters

signal respawn_player(player: Node)

const player_character_scene = preload("res://components/fps_character/fps_character.tscn")


func _ready():
	Server.spawn_player_character.connect(add_player_character)
	Server.despawn_player_character.connect(remove_player_character)


func add_player_character(peer_id: int):
	# Spawn a new character for this player to control
	var player_character = player_character_scene.instantiate()
	# Set the player character's name to the peer_id of the Player who owns it
	player_character.name = str(peer_id)
	player_character.set_multiplayer_authority(peer_id)
	add_child(player_character)


func remove_player_character(peer_id: int):
	for player in get_children():
		if player.name == str(peer_id):
			player.queue_free()


func delete_all_players():
	for p in get_children():
		p.queue_free()


func update_player_name(peer_id: int, new_name: String):
	for p in get_children():
		if p.name == str(peer_id):
			p.set_player_name(new_name)
			return
	push_warning("Failed to update name for peer_id: ", peer_id, ", could not find them.")
	


func on_new_map_loaded(_map_name: String):
	respawn_players()


func respawn_players():
	for p in get_children():
		print("Respawning player: ", p.name)
		respawn_player.emit(p)
