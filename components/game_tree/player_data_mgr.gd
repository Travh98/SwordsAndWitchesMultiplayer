class_name PlayerDataMgr
extends Node

## Manages our records of all the Player's PlayerData

signal player_name_changed(peer_id: int, new_name: String)

@onready var random_name_gen: RandomNameGen = $RandomNameGen

var local_player_name: String = "unset player name"
var player_data: Dictionary = {}


func _ready():
	# Assign a random name to this Client on startup
	local_player_name = random_name_gen.get_random_name()


func on_player_name_changed(peer_id: int, new_name: String):
	if !GameMgr.is_valid_name(new_name):
		push_warning("Someone RPCd an invalid player name: ", peer_id)
		return
	
	#print("PlayerDataMgr: Storing Player name for ", peer_id, " as ", new_name)
	
	player_name_changed.emit(peer_id, new_name)


func on_local_player_name_changed(new_name: String):
	if !GameMgr.is_valid_name(new_name):
		return
	
	local_player_name = new_name
	
	if Server.server_connector.is_server_connected:
		Server.peer_name_changed.rpc(multiplayer.multiplayer_peer.get_unique_id(), new_name)


func on_server_connection_changed(connected: bool):
	if !connected:
		return
	
	Server.peer_name_changed.rpc(multiplayer.multiplayer_peer.get_unique_id(), local_player_name)
	#Server.send_player_data.rpc_id(1, 
		#multiplayer.multiplayer_peer.get_unique_id(),
		#local_player_name, Color.CHOCOLATE)


func receive_player_data(in_data):
	# Replace our data with incoming data
	player_data = in_data.duplicate()
	
	for peer_id in player_data:
		player_name_changed.emit(peer_id, player_data[peer_id]["name"])

