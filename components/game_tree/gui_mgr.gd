class_name GuiMgr
extends Node

## Manages GUI elements

signal local_player_name_changed(new_name: String)

@onready var start_menu: StartMenu = $StartMenu
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var server_info: ServerInfo = $ServerInfo
@onready var ttt_hud: Control = $TttHud


func _ready():
	start_menu.join_server.connect(on_join_button_pressed)
	pause_menu.disconnect.connect(Server.server_connector.disconnect_from_server)
	start_menu.name_selected.connect(on_local_name_changed)
	pause_menu.change_name.connect(on_local_name_changed)
	Server.server_connection_changed.connect(on_server_connection_changed)


func on_local_name_changed(new_name: String):
	if !GameMgr.is_valid_name(new_name):
		return
	
	pause_menu.update_name(new_name)
	local_player_name_changed.emit(new_name)


func on_join_button_pressed(host_ip: String, p: int):
	start_menu.hide()
	GameMgr.unpause_game()
	
	server_info.start_connecting_ui()
	Server.server_connector.set_server_connection_info(host_ip, p)
	Server.server_connector.connect_to_server()


func on_server_disconnected():
	return_to_start_menu()


func on_connection_failed():
	return_to_start_menu()


func on_connection_success():
	server_info.hide_connecting_ui()
	start_menu.hide()
	
	# Delay the updating of the name so that the player can spawn probably
	await get_tree().create_timer(1).timeout
	
	on_local_name_changed(GameMgr.game_tree.player_data_mgr.local_player_name)


func on_disconnect():
	return_to_start_menu()


func on_server_connection_changed(connected: bool):
	if !connected:
		return_to_start_menu()


func return_to_start_menu():
	server_info.hide_connecting_ui()
	start_menu.show()
	pause_menu.hide()
	ttt_hud.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func show_ttt_hud():
	ttt_hud.show()


func hide_ttt_hud():
	ttt_hud.hide()
