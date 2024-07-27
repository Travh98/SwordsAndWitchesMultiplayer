extends Node

## Singleton Interface to the Server
## Inspired by tutorial: https://www.youtube.com/watch?v=lnFN6YabFKg&list=PLZ-54sd-DMAKU8Neo5KsVmq8KtoDkfi4s
## All rpc functions must match on the Server and the Client Godot projects
## This Interface must attached to the scene tree at /root/Server for the Client and the Server to match.
## Since this is an Autoload, this script is at that path.

var network: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var host_ip: String = "localhost"
var port: int = 25026

#func _ready():
	#connect_to_server()
#
#
#func connect_to_server():
	#network.create_client(host_ip, port)
	#multiplayer.multiplayer_peer = network
	#
	#multiplayer.connection_failed.connect(on_connection_failed)
	#multiplayer.connected_to_server.connect(on_connection_success)
	#
	#
#func on_connection_failed():
	#print("Connection Failed!")
	#
#func on_connection_success():
	#print("Successfully connected!")
