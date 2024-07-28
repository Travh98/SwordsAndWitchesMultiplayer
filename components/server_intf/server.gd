extends Node

## Singleton Interface to the Server
## Inspired by tutorial: https://www.youtube.com/watch?v=lnFN6YabFKg&list=PLZ-54sd-DMAKU8Neo5KsVmq8KtoDkfi4s
## All rpc functions must match on the Server and the Client Godot projects
## This Interface must attached to the scene tree at /root/Server for the Client and the Server to match.
## Since this is an Autoload, this script is at that path.

signal ping_calculated(ping: float)

const player_character_scene = preload("res://components/fps_character/fps_character.tscn")

@onready var ping_timer: Timer = Timer.new()

var network: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var host_ip: String = "localhost"
var port: int = 25026
var last_join_attempt_secs: float
var server_connected: bool = false
var ping_start_time_msec: float


func _ready():
	add_child(ping_timer)
	ping_timer.wait_time = 1
	ping_timer.one_shot = false
	ping_timer.timeout.connect(start_ping)
	pass


func set_server_connection_info(h: String, p: int):
	if !h.is_empty():
		host_ip = h
	if p > 1023 && p < 65535:
		port = p


func connect_to_server():
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
func ping_to_server(peer_id: int):
	# Input peer_id tells the server who to pong back to
	pass


@rpc("call_remote")
func pong_to_client():
	# Called from server
	var ping: float = Time.get_ticks_msec() - ping_start_time_msec
	ping_calculated.emit(ping)
