extends Node

signal new_player(peer_id: int, user_name: String)
var players: Dictionary
var last_ping_time: float  


func _ready():
	if not is_multiplayer_authority(): return
#	ConsoleLog.log_msg("Setting up Multiplayer Mgr as host")


## Any client can call this, this will run on the host
#@rpc("any_peer", "call_local", "unreliable")
#func register_player(peer_id: int, user_name: String):
	#if !multiplayer.is_server():
		#return
	#
	#players[peer_id] = user_name
	#
	## Tell our local componnets
	#new_player.emit(peer_id, user_name)
	#
	#for stored_peer_id in players:
		#MultiplayerMgr.receive_player_info.rpc(stored_peer_id, players[stored_peer_id])
#
#
#@rpc("any_peer", "call_local", "unreliable")
#func receive_player_info(peer_id: int, user_name: String):
	#new_player.emit(peer_id, user_name)
#
#
#@rpc("any_peer")
#func ping(target_id: int, iam_asking: bool = true) -> void:  
	#if iam_asking:  
		#last_ping_time = Time.get_unix_time_from_system()
		#ping.rpc(target_id, false)  
	#else:  
		#var sender_id: int = multiplayer.get_remote_sender_id()
		#print_ping.rpc(sender_id)
#
#
#@rpc("any_peer")      
#func print_ping():
	#print("Ping delay: ", str(Time.get_unix_time_from_system() - last_ping_time))  
