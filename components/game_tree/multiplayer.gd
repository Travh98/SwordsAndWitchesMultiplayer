class_name GameTree
extends Node

# Multiplayer Settings
var host_addr: String = "localhost"
var port: int = 25026
const player_character_scene = preload("res://components/fps_character/fps_character.tscn")

# UI Components
@onready var start_menu: StartMenu = $StartMenu
@onready var server_info: ServerInfo = $ServerInfo
@onready var pause_menu: PauseMenu = $PauseMenu
# Level
@onready var current_level: Node3D = $CurrentLevel
var level: Level

const local_testing_quick_start: bool = true
const quick_quit_game: bool = true


func _ready():
	GameMgr.game_tree = self
	
	level = current_level.get_child(0)
	
	start_menu.host_server.connect(on_host_button_pressed)
	start_menu.join_server.connect(on_join_button_pressed)
	start_menu.name_selected.connect(on_name_change)
	
	pause_menu.disconnect.connect(on_disconnect)
	pause_menu.change_name.connect(on_name_change)
	
	MultiplayerMgr.new_player.connect(server_info.add_player_entry)


func on_host_button_pressed(p: int):
	if p > 1023 && p < 65535:
		port = p
	
	start_menu.hide()
	setup_network(true)
	# Add a character for the Host to own and control
	add_player_character(multiplayer.get_unique_id())

func on_join_button_pressed(host_ip: String, p: int):
	if !host_ip.is_empty():
		host_addr = host_ip
	if p > 1023 && p < 65535:
		port = p
	start_menu.hide()
	setup_network(false)

func setup_network(is_host: bool):
	var enet_peer = ENetMultiplayerPeer.new()
	if is_host:
		print("Setting up server as host")
		enet_peer.create_server(port)
		
		# Setup signal-slot functions to handle when Players join
		multiplayer.peer_connected.connect(on_peer_connected)
		multiplayer.peer_disconnected.connect(on_peer_disconnected)
		upnp_setup()
		
	else:
#		ConsoleLog.log_msg(str("Joining as client to ", join_address))
		print("Joining as client to ", host_addr)
		enet_peer.create_client(host_addr, port)
		
		multiplayer.connected_to_server.connect(on_connected_to_server)
		multiplayer.connection_failed.connect(on_connection_failed)
		multiplayer.server_disconnected.connect(on_server_disconnected)
	
	multiplayer.multiplayer_peer = enet_peer
	#ConsoleLog.log_msg("My multiplayer ID: " + str(multiplayer.get_unique_id()))

func upnp_setup():
	var upnp = UPNP.new()
	
	if local_testing_quick_start:
		#ConsoleLog.log_msg("Running the game with quick local test start enabled, local connections only")
		print("Local testing quick start")
		return
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
	"UPNP Discover Failed! Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
	"UPNP Invalid Gateway!")
	
	var map_result = upnp.add_port_mapping(port)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
	"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Server listening on Address %s" % upnp.query_external_address()) 

func on_peer_connected(peer_id: int):
	print("Peer connected: ", peer_id )
	add_player_character(peer_id)

func on_peer_disconnected(peer_id: int):
	remove_player_character(peer_id)

func add_player_character(peer_id):
	# Spawn a new character for this player to control
	var player_character = player_character_scene.instantiate()
	# Set the player character's name to the peer_id of the Player who owns it
	player_character.name = str(peer_id)
	add_child(player_character)
	player_character.player_name = GameMgr.player_name


func remove_player_character(peer_id):
	# Find and despawn the character that peer is controlling
	var player_character = get_node_or_null(str(peer_id))
	if player_character:
		#ConsoleLog.log_msg(str(player_character.get_node("PlayerController").player_name, " has left the game, was peer: ", str(peer_id)))
		player_character.queue_free()


func on_server_disconnected():
	#ConsoleLog.log_msg("Server disconnected")
	start_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func on_connection_failed():
	#ConsoleLog.log_msg("Connection failed")
	start_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func on_connected_to_server():
	#ConsoleLog.log_msg("Connection successful")
	pass


func _input(_event):
	if Input.is_action_just_pressed("quit_game"):
		get_tree().quit()


func on_disconnect():
	multiplayer.multiplayer_peer = null
	start_menu.show()
	pause_menu.hide()
	remove_player_character(get_multiplayer_authority())


func on_name_change(n: String):
	GameMgr.on_name_selected(n)
