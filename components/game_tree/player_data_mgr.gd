class_name PlayerDataMgr
extends Node

## Manages our records of all the Player's PlayerData

signal player_name_changed(peer_id: int, new_name: String)

const PLAYER_DATA = preload("res://components/game_tree/player_data.tscn")

@onready var random_name_gen: RandomNameGen= $RandomNameGen

var local_player_name: String = ""
var player_data_nodes: Dictionary


func _ready():
	# Assign a random name to this Client on startup
	local_player_name = random_name_gen.get_random_name()


func create_player_data(peer_id: int):
	var player_data: Node = PLAYER_DATA.instantiate()
	player_data.name = str(peer_id)
	add_child(player_data)
	player_data_nodes[peer_id] = player_data


func delete_player_data(peer_id: int):
	if player_data_nodes.has(peer_id):
		player_data_nodes[peer_id].queue_free()
		player_data_nodes.erase(peer_id)


func on_player_name_changed(peer_id: int, new_name: String):
	print("PlayerDataMgr: Storing Player name for ", peer_id, " as ", new_name)
	if !player_data_nodes.has(peer_id):
		push_warning("Invalid peer_id for setting PlayerData: ", peer_id)
		return
	player_data_nodes[peer_id].player_name = new_name
	player_name_changed.emit(peer_id, new_name)


func on_local_player_name_changed(new_name: String):
	local_player_name = new_name


func on_server_connection_changed(connected: bool):
	if !connected:
		return
	
	#await get_tree().create_timer(2).timeout
	#
	#print("PlayerDataMgr: Joined server, sending my local name: ", local_player_name)
	#var local_peer_id: int = multiplayer.multiplayer_peer.get_unique_id()
	#Server.peer_name_changed.rpc(local_peer_id, player_data_nodes[local_peer_id].player_name)
