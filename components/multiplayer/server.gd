extends Node

## Singleton Interface to the Server
## Inspired by tutorial: https://www.youtube.com/watch?v=lnFN6YabFKg&list=PLZ-54sd-DMAKU8Neo5KsVmq8KtoDkfi4s
## All rpc functions must match on the Server and the Client Godot projects
## This Interface must attached to the scene tree at /root/Server for the Client and the Server to match.

signal server_connection_changed(connected: bool)
signal ping_calculated(ping: float)
signal spawn_player_character(peer_id: int)
signal despawn_player_character(peer_id: int)
signal level_gen_tiles_received(tiles_str: String)
signal change_map(map_name: String)
signal change_gamemode(mode_name: String)
signal player_name_changed(peer_id: int, new_name: String)
signal player_faction_changed(peer_id: int, faction_name: String)
signal player_data_received(player_data: Dictionary)
signal player_health_updated(peer_id: int, new_health: int)
signal respawn_all_players()
signal gamemode_stage_updated(new_stage: String)
signal game_stage_time_left_updated(time_left: int)
signal ttt_winner_decided(traitors_won: bool)
signal player_equipped_slot_changed(peer_id: int, slot_index: int)
signal player_selected_hat(peer_id: int, file_name: String)

@onready var server_connector: ServerConnector = $ServerConnector
@onready var game_state_mgr: GameStateMgr = $GameStateMgr
@onready var npc_mgr: NpcMgr = $NpcMgr


func _ready():
	# Daisy chaining Server Management signals so the Game only needs to ask this Server interface
	server_connector.server_connection_changed.connect(func(connected: bool): self.server_connection_changed.emit(connected))
	server_connector.ping_mgr.ping_calculated.connect(func(ping: float): self.ping_calculated.emit(ping))


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
	player_name_changed.emit(peer_id, new_name)


@rpc("call_remote", "reliable")
func generated_level_tiles(tile_str: String):
	level_gen_tiles_received.emit(tile_str)


@rpc("call_remote")
func client_spawn_red_knight():
	npc_mgr.spawn_knight(true)


@rpc("call_remote")
func client_spawn_blue_knight():
	npc_mgr.spawn_knight(false)


@rpc("call_remote", "reliable")
func mode_changed(mode_name: String):
	change_gamemode.emit(mode_name)


@rpc("call_remote", "reliable")
func map_changed(map_name: String):
	change_map.emit(map_name)


@rpc("call_remote")
func assign_player_faction(peer_id: int, faction_name: String):
	player_faction_changed.emit(peer_id, faction_name)
	pass


#@rpc("any_peer")
#func send_player_data(_peer_id: int, _player_name: String, _player_color: Color):
	#pass


@rpc("call_remote")
func send_player_data_from_server(player_data: Dictionary):
	# Update our player data
	player_data_received.emit(player_data)
	pass


@rpc("any_peer", "reliable")
func damage_entity(_damager_id: int, _target_id: int, _damage: int):
	pass


@rpc("call_remote")
func player_health_changed(peer_id: int, new_health: int):
	player_health_updated.emit(peer_id, new_health)
	pass


@rpc("call_remote")
func respawn_players():
	respawn_all_players.emit()


@rpc("call_remote", "reliable")
func gamemode_stage_changed(stage_name: String):
	gamemode_stage_updated.emit(stage_name)
	pass


@rpc("call_remote", "reliable")
func gamemode_stage_time_left(time_left: int):
	game_stage_time_left_updated.emit(time_left)
	pass


@rpc("call_remote", "reliable")
func ttt_team_won(traitors_won: bool):
	ttt_winner_decided.emit(traitors_won)
	pass


@rpc("any_peer", "reliable")
func player_equipped_slot(peer_id: int, slot_index: int):
	player_equipped_slot_changed.emit(peer_id, slot_index)
	pass


@rpc("any_peer", "reliable")
func peer_hat_selected(peer_id: int, file_name: String):
	player_selected_hat.emit(peer_id, file_name)
	pass
