class_name GameStateMgr
extends Node

## Manages the gamemodes

enum ServerMode {
	MODE_PVE,
	MODE_TTT,
	MODE_FFA,
}

var server_mode: ServerMode = ServerMode.MODE_PVE


func _ready():
	Server.change_gamemode.connect(on_game_mode_changed)


func on_game_mode_changed(mode_str: String):
	handle_gamemode_end(server_mode)
	server_mode = ServerMode.get(mode_str)
	#print("Gamemode: ", ServerMode.keys()[server_mode])
	
	match server_mode:
		ServerMode.MODE_PVE:
			pass
		ServerMode.MODE_TTT:
			GameMgr.game_tree.gui_mgr.show_ttt_hud()
		ServerMode.MODE_FFA:
			pass


func handle_gamemode_end(old_mode: ServerMode):
	match old_mode:
		ServerMode.MODE_PVE:
			pass
		ServerMode.MODE_TTT:
			GameMgr.game_tree.gui_mgr.hide_ttt_hud()
		ServerMode.MODE_FFA:
			pass
