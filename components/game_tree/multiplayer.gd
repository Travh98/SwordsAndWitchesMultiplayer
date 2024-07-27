class_name GameTree
extends Node

## Manages the tree items (UI, Current Level, Camera)



@onready var multiplayer_starter: MultiplayerStarter = $MultiplayerStarter

# UI Components
@onready var start_menu: StartMenu = $StartMenu
@onready var server_info: ServerInfo = $ServerInfo
@onready var pause_menu: PauseMenu = $PauseMenu

# Level
@onready var current_level: Node3D = $CurrentLevel

var level: Level

const quick_quit_game: bool = true


func _ready():
	GameMgr.game_tree = self
	
	level = current_level.get_child(0)
	
	# Connect the tree
	start_menu.host_server.connect(on_host_button_pressed)
	start_menu.join_server.connect(on_join_button_pressed)
	start_menu.name_selected.connect(on_name_change)
	
	pause_menu.disconnect.connect(on_disconnect)
	pause_menu.change_name.connect(on_name_change)
	
	multiplayer_starter.server_disconnected.connect(on_server_disconnected)
	multiplayer_starter.connection_failed.connect(on_connection_failed)
	multiplayer_starter.connection_success.connect(on_connection_success)
	
	MultiplayerMgr.new_player.connect(server_info.add_player_entry)


func _input(_event):
	if Input.is_action_just_pressed("quit_game"):
		get_tree().quit()


func on_name_change(n: String):
	GameMgr.on_name_selected(n)


#region Multiplayer Hooks
func on_host_button_pressed(p: int):
	start_menu.hide()
	
	multiplayer_starter.set_port(p)
	multiplayer_starter.setup_network(true)
	# Add a character for the Host to own and control
	multiplayer_starter.add_player_character(multiplayer.get_unique_id())


func on_join_button_pressed(host_ip: String, p: int):
	start_menu.hide()
	
	multiplayer_starter.set_host(host_ip)
	multiplayer_starter.set_port(p)
	multiplayer_starter.setup_network(false)


func on_server_disconnected():
	#ConsoleLog.log_msg("Server disconnected")
	start_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func on_connection_failed():
	#ConsoleLog.log_msg("Connection failed")
	start_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func on_connection_success():
	# Delay the updating of the name so that the player can spawn probably
	await get_tree().create_timer(1).timeout
	
	on_name_change(start_menu.get_player_name())


func on_disconnect():
	multiplayer.multiplayer_peer = null
	start_menu.show()
	pause_menu.hide()
	multiplayer_starter.remove_player_character(get_multiplayer_authority())
#endregion


