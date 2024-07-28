class_name MultiplayerStarter
extends Node

## Hosts or Joins the server, mostly responsible for startup duties


#signal connection_success()
#signal connection_failed()
#signal server_disconnected()
#
## Avoid opening the UPNP system and just run locally
#const local_testing_quick_start: bool = false
#const player_character_scene = preload("res://components/fps_character/fps_character.tscn")
#
## Multiplayer Settings
#var host_addr: String = "localhost" : set = set_host
#var port: int = 25026 : set = set_port
#
#
#func set_host(h: String):
	#if !h.is_empty():
		#host_addr = h
	#else:
		#push_warning("Host Address was empty, defaulting to: ", host_addr)
#
#
#func set_port(p: int):
	#if p > 1023 && p < 65535:
		#port = p
	#else:
		#push_warning("Port was empty/invalid, defaulting to: ", port)
#
#
#func setup_network(is_host: bool):
	#var enet_peer = ENetMultiplayerPeer.new()
	#if is_host:
		#print("Setting up server as host")
		#enet_peer.create_server(port)
		#
		## Setup signal-slot functions to handle when Players join
		#multiplayer.peer_connected.connect(on_peer_connected)
		#multiplayer.peer_disconnected.connect(on_peer_disconnected)
		#upnp_setup()
		#
	#else:
##		ConsoleLog.log_msg(str("Joining as client to ", join_address))
		#print("Joining as client to ", host_addr)
		#enet_peer.create_client(host_addr, port)
		#
		#multiplayer.connected_to_server.connect(on_connected_to_server)
		#multiplayer.connection_failed.connect(on_connection_failed)
		#multiplayer.server_disconnected.connect(on_server_disconnected)
	#
	#multiplayer.multiplayer_peer = enet_peer
#
#
#func upnp_setup():
	#var upnp = UPNP.new()
	#
	#if local_testing_quick_start:
		##ConsoleLog.log_msg("Running the game with quick local test start enabled, local connections only")
		#print("Local testing quick start")
		#return
	#
	#var discover_result = upnp.discover()
	#assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
	#"UPNP Discover Failed! Error %s" % discover_result)
	#
	#assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
	#"UPNP Invalid Gateway!")
	#
	#var map_result = upnp.add_port_mapping(port)
	#assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
	#"UPNP Port Mapping Failed! Error %s" % map_result)
	#
	#print("Success! Server listening on Address %s" % upnp.query_external_address()) 
#
#
#func on_peer_connected(peer_id: int):
	#print("Peer connected: ", peer_id )
	#add_player_character(peer_id)
#
#
#func on_peer_disconnected(peer_id: int):
	#remove_player_character(peer_id)
#
#
#func add_player_character(peer_id):
	## Spawn a new character for this player to control
	#var player_character = player_character_scene.instantiate()
	## Set the player character's name to the peer_id of the Player who owns it
	#player_character.name = str(peer_id)
	#GameMgr.game_tree.add_child(player_character, true) # Forcing readable name to help with RPCs
	#player_character.player_name = GameMgr.player_name
#
#
#func remove_player_character(peer_id):
	## Find and despawn the character that peer is controlling
	#var player_character = get_node_or_null(str(peer_id))
	#if player_character:
		##ConsoleLog.log_msg(str(player_character.get_node("PlayerController").player_name, " has left the game, was peer: ", str(peer_id)))
		#player_character.queue_free()
#
#
#func on_server_disconnected():
	#server_disconnected.emit()
#
#
#func on_connection_failed():
	#connection_failed.emit()
#
#func on_connected_to_server():
	##ConsoleLog.log_msg("Connection successful")
	#connection_success.emit()
	#pass
