extends Node

## Singleton Interface to the Server
## Inspired by tutorial: https://www.youtube.com/watch?v=lnFN6YabFKg&list=PLZ-54sd-DMAKU8Neo5KsVmq8KtoDkfi4s
## All rpc functions must match on the Server and the Client Godot projects
## This Interface must attached to the scene tree at /root/Server for the Client and the Server to match.
## Since this is an Autoload, this script is at that path.

signal server_connection_changed(connected: bool)
signal ping_calculated(ping: float)
signal spawn_player_character(peer_id: int)
signal despawn_player_character(peer_id: int)

signal level_gen_tiles_received(tiles_str: String)
signal change_map(map_name: String)
signal change_gamemode(mode_name: String)

@onready var server_connector: ServerConnector = $ServerConnector


const ENEMY_KNIGHT = preload("res://entities/test_enemies/enemy_knight.tscn")

enum ServerMode {
	MODE_PVE,
	MODE_TTT,
}

var server_mode: ServerMode = ServerMode.MODE_PVE


func _ready():
	# Daisy chaining Server Management signals so the Game only needs to ask this Server interface
	server_connector.server_connection_changed.connect(func(connected: bool): self.server_connection_changed.emit(connected))
	server_connector.ping_mgr.ping_calculated.connect(func(ping: float): self.ping_calculated.emit(ping))


func spawn_knight(red: bool):
	var k = ENEMY_KNIGHT.instantiate()
	if red:
		k.faction = FactionMgr.Factions.RED
	else:
		k.faction = FactionMgr.Factions.BLUE
	GameMgr.game_tree.level.npcs.add_child(k)


func on_game_mode_changed(mode_str: String):
	server_mode = ServerMode.get(mode_str)


@rpc("call_remote", "reliable")
func add_newly_connected_player_character(peer_id: int):
	spawn_player_character.emit(peer_id)


@rpc("call_remote", "reliable")
func add_previously_connected_player_characters(peer_ids: Array):
	for peer_id in peer_ids:
		spawn_player_character.emit(peer_id)


@rpc("call_remote", "reliable")
func remove_existing_player_character(peer_id: int):
	despawn_player_character.emit(peer_id)


@rpc("any_peer")
func ping_to_server(_peer_id: int):
	# Input peer_id tells the server who to pong back to
	pass


@rpc("call_remote")
func pong_to_client():
	# Called from server
	server_connector.ping_mgr.receive_pong()

@rpc("any_peer")
func report_ping_to_server(_peer_id: int, _ping: float):
	pass


@rpc("any_peer", "reliable")
func peer_name_changed(peer_id: int, new_name: String):
	print("Peer ", peer_id, " changed name to: ", new_name)
	GameMgr.game_tree.player_mgr.update_player_name(peer_id, new_name)


#@rpc("call_remote")
#func spawn_new_entity(ent_name: String, global_pos: Vector3):
	#print("Server declares new entity: ", ent_name, " at pos: ", global_pos)
	#pass


#@rpc("call_remote")
#func spawn_existing_entities(entities: Array):
	#pass


# TODO: First client that joins, declares where the existing entities are
#@rpc("any_peer")
#func declare_existing_entities(entities: Array):
	#pass


@rpc("call_remote", "reliable")
func generated_level_tiles(tile_str: String):
	level_gen_tiles_received.emit(tile_str)
	pass


@rpc("call_remote")
func client_spawn_red_knight():
	spawn_knight(true)
	pass


@rpc("call_remote")
func client_spawn_blue_knight():
	spawn_knight(false)
	pass


@rpc("call_remote", "reliable")
func mode_changed(mode_name: String):
	print("new mode: ", mode_name)
	change_gamemode.emit(mode_name)
	pass


@rpc("call_remote", "reliable")
func map_changed(map_name: String):
	print("new map: ", map_name)
	change_map.emit(map_name)
	pass
