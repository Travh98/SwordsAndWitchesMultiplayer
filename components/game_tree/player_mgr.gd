class_name PlayerMgr
extends Node

## Manages player characters

signal respawn_player(player: Node)
signal local_player_spawned(player: Node3D)

const player_character_scene = preload("res://components/fps_character/fps_character.tscn")


func _ready():
	Server.spawn_player_character.connect(add_player_character)
	Server.despawn_player_character.connect(remove_player_character)
	Server.player_faction_changed.connect(on_player_faction_changed)
	Server.player_health_updated.connect(on_player_health_changed)
	Server.respawn_all_players.connect(respawn_players)
	Server.player_equipped_slot_changed.connect(on_player_equipment_changed)
	Server.player_selected_hat.connect(on_player_hat_selected)


func add_player_character(peer_id: int):
	if does_player_exist(peer_id):
		print("Player ", peer_id, " already exists")
		return
	
	# Spawn a new character for this player to control
	var player_character = player_character_scene.instantiate()
	# Set the player character's name to the peer_id of the Player who owns it
	player_character.name = str(peer_id)
	player_character.set_multiplayer_authority(peer_id)
	add_child(player_character)
	
	if peer_id == Server.server_connector.get_peer_id():
		local_player_spawned.emit(player_character)


func remove_player_character(peer_id: int):
	for player in get_children():
		if player.name == str(peer_id):
			player.queue_free()


func delete_all_players():
	for p in get_children():
		p.queue_free()


func update_player_name(peer_id: int, new_name: String):
	#print(peer_id, " new name: ", new_name)
	var player = get_player(peer_id)
	if player:
		player.set_player_name(new_name)
		return
	push_warning("Failed to update name for peer_id: ", peer_id, ", could not find them.")


func on_player_faction_changed(peer_id: int, faction_name: String):
	var player = get_player(peer_id)
	if player:
		player.faction = FactionMgr.get_faction_from_string(faction_name)
		return


func on_player_health_changed(peer_id: int, new_health: int):
	var player = get_player(peer_id)
	if player:
		var hp: HealthComponent = player.get_node("HealthComponent")
		hp.health = new_health


func on_player_equipment_changed(peer_id: int, slot_index: int):
	var player = get_player(peer_id)
	if player:
		player.set_equipment_slot(slot_index)


func on_player_hat_selected(peer_id: int, file_name: String):
	var player = get_player(peer_id)
	if player:
		player.set_hat(file_name)


func on_new_map_loaded(_map_name: String):
	respawn_players()


func respawn_players():
	for p in get_children():
		respawn_player.emit(p)


func does_player_exist(peer_id: int):
	for player in get_children():
		if player.name == str(peer_id):
			return true
	return false


func get_player(peer_id: int) -> Node:
	for p in get_children():
		if p.name == str(peer_id):
			return p
	return null


func get_players() -> Array:
	return get_children()
