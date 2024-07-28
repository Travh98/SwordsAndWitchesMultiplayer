extends Node

## Singleton Interface to the Server
## Inspired by tutorial: https://www.youtube.com/watch?v=lnFN6YabFKg&list=PLZ-54sd-DMAKU8Neo5KsVmq8KtoDkfi4s
## All rpc functions must match on the Server and the Client Godot projects
## This Interface must attached to the scene tree at /root/Server for the Client and the Server to match.
## Since this is an Autoload, this script is at that path.

signal ping_calculated(ping: float)
signal level_gen_tiles_received(tiles_str: String)

const player_character_scene = preload("res://components/fps_character/fps_character.tscn")

@onready var ping_timer: Timer = Timer.new()

var network: ENetMultiplayerPeer
var host_ip: String = "localhost"
var port: int = 25026
var last_join_attempt_secs: float
var server_connected: bool = false
var ping_start_time_msec: float
var report_ping_interval: int = 5
var num_pings: int = 0


func _ready():
	add_child(ping_timer)
	ping_timer.wait_time = 1
	ping_timer.one_shot = false
	ping_timer.timeout.connect(start_ping)
	
	GameMgr.name_changed.connect(update_name)
	pass


func set_server_connection_info(h: String, p: int):
	if !h.is_empty():
		host_ip = h
	if p > 1023 && p < 65535:
		port = p


func connect_to_server():
	network = ENetMultiplayerPeer.new()
	last_join_attempt_secs = Time.get_unix_time_from_system()
	network.create_client(host_ip, port)
	multiplayer.multiplayer_peer = network
	
	multiplayer.connection_failed.connect(on_connection_failed)
	multiplayer.connected_to_server.connect(on_connection_success)


func on_connection_failed():
	server_connected = false
	var time_spent_joining: float = Time.get_unix_time_from_system() - last_join_attempt_secs
	push_warning("Connection failed after ", str(time_spent_joining), " seconds.")
	GameMgr.game_tree.on_connection_failed()
	multiplayer.multiplayer_peer = null


func on_connection_success():
	server_connected = true
	print("Successfully connected!")
	GameMgr.game_tree.on_connection_success()
	
	# Start pinging server
	ping_timer.start()


func add_player_character(peer_id: int):
	# Spawn a new character for this player to control
	var player_character = player_character_scene.instantiate()
	# Set the player character's name to the peer_id of the Player who owns it
	player_character.name = str(peer_id)
	player_character.set_multiplayer_authority(peer_id)
	GameMgr.game_tree.players.add_child(player_character)


func remove_player_character(peer_id: int):
	for player in GameMgr.game_tree.players.get_children():
		if player.name == str(peer_id):
			player.queue_free()


func start_ping():
	if server_connected:
		ping_start_time_msec = Time.get_ticks_msec()
		# Ping the server, telling it who to respond to
		ping_to_server.rpc_id(1, multiplayer.multiplayer_peer.get_unique_id())


func report_ping(ping: float):
	# Report every couple pings
	if num_pings > report_ping_interval:
		report_ping_to_server.rpc_id(1, 
			multiplayer.multiplayer_peer.get_unique_id(), ping)
		num_pings = 0
	num_pings += 1


func disconnect_from_server():
	server_connected = false
	multiplayer.multiplayer_peer = null
	GameMgr.game_tree.delete_all_players()


func update_name(my_new_name: String):
	if server_connected:
		peer_name_changed.rpc(multiplayer.multiplayer_peer.get_unique_id(), my_new_name)


@rpc("call_remote")
func add_newly_connected_player_character(peer_id: int):
	add_player_character(peer_id)


@rpc("call_remote")
func add_previously_connected_player_characters(peer_ids: Array):
	for peer_id in peer_ids:
		add_player_character(peer_id)


@rpc("call_remote")
func remove_existing_player_character(peer_id: int):
	remove_player_character(peer_id)


@rpc("any_peer")
func ping_to_server(_peer_id: int):
	# Input peer_id tells the server who to pong back to
	pass


@rpc("call_remote")
func pong_to_client():
	# Called from server
	var ping: float = Time.get_ticks_msec() - ping_start_time_msec
	ping_calculated.emit(ping)
	report_ping(ping)

@rpc("any_peer")
func report_ping_to_server(_peer_id: int, _ping: float):
	pass


@rpc("any_peer")
func peer_name_changed(peer_id: int, new_name: String):
	GameMgr.game_tree.update_player_name(peer_id, new_name)
	print("Peer ", peer_id, " changed name to: ", new_name)


@rpc("call_remote")
func spawn_new_entity(ent_name: String, global_pos: Vector3):
	print("Server declares new entity: ", ent_name, " at pos: ", global_pos)
	pass


@rpc("call_remote")
func spawn_existing_entities(entities: Array):
	pass


# TODO: First client that joins, declares where the existing entities are
#@rpc("any_peer")
#func declare_existing_entities(entities: Array):
	#pass


@rpc("call_remote")
func generated_level_tiles(tile_str: String):
	level_gen_tiles_received.emit(tile_str)
	pass
