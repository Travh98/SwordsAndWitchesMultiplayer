class_name GameStateMgr
extends Node

## Manages the gamemodes

enum ServerMode {
	MODE_PVE,
	MODE_TTT,
}

var server_mode: ServerMode = ServerMode.MODE_PVE


func _ready():
	Server.change_gamemode.connect(on_game_mode_changed)


func on_game_mode_changed(mode_str: String):
	server_mode = ServerMode.get(mode_str)
	print("Gamemode: ", ServerMode.keys()[server_mode])
