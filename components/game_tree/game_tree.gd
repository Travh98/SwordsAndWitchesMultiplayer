class_name GameTree
extends Node

## Manages the tree items (UI, Current Level, Camera)


@onready var players: Node = $Players

# UI Components
@onready var start_menu: StartMenu = $StartMenu
@onready var server_info: ServerInfo = $ServerInfo
@onready var pause_menu: PauseMenu = $PauseMenu

# Level
@onready var current_level: Node3D = $CurrentLevel

var level: Level : get = get_level

const quick_quit_game: bool = true


func _ready():
	GameMgr.game_tree = self
	
	update_level()
	
	# Connect the tree
	start_menu.join_server.connect(on_join_button_pressed)
	start_menu.name_selected.connect(on_name_change)
	
	pause_menu.disconnect.connect(on_disconnect)
	pause_menu.change_name.connect(on_name_change)
	
	Server.change_map.connect(on_map_change)


func _input(_event):
	if Input.is_action_just_pressed("quit_game"):
		get_tree().quit()


func on_name_change(n: String):
	GameMgr.on_name_selected(n)


func delete_all_players():
	for p in players.get_children():
		p.queue_free()


func update_player_name(peer_id: int, new_name: String):
	for p in players.get_children():
		if p.name == str(peer_id):
			p.set_player_name(new_name)


func update_level():
	level = current_level.get_child(0)
	# Rename the loaded level to match the scene tree on the Server
	level.name = "Level"


func get_level() -> Level:
	return current_level.get_child(0)


func on_map_change(map_name: String):
	update_level()
	var new_map: Node
	var new_map_path: String = "res://levels/" + map_name + ".tscn"
	if !ResourceLoader.exists(new_map_path):
		push_warning("Missing map: ", new_map_path)
		return
	
	new_map = load(new_map_path).instantiate()
	level.queue_free()
	current_level.add_child(new_map)
	update_level()
	await get_tree().create_timer(1).timeout
	#print("Respawning players")
	respawn_players.call_deferred()


func respawn_players():
	for p in players.get_children():
		print("Respawniing player: ", p.name)
		level.respawn_entity(p)
		#print("Respawning players. ", get_multiplayer_authority(), " vs ", p.get_multiplayer_authority())
		#if get_multiplayer_authority() == p.get_multiplayer_authority():
			


#region Multiplayer Hooks
func on_join_button_pressed(host_ip: String, p: int):
	start_menu.hide()
	GameMgr.unpause_game()
	
	server_info.start_connecting_ui()
	Server.set_server_connection_info(host_ip, p)
	Server.connect_to_server()


func on_server_disconnected():
	#ConsoleLog.log_msg("Server disconnected")
	start_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func on_connection_failed():
	#ConsoleLog.log_msg("Connection failed")
	server_info.hide_connecting_ui()
	start_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func on_connection_success():
	server_info.hide_connecting_ui()
	
	# Delay the updating of the name so that the player can spawn probably
	await get_tree().create_timer(1).timeout
	
	on_name_change(start_menu.get_player_name())


func on_disconnect():
	start_menu.show()
	pause_menu.hide()
	Server.disconnect_from_server()
#endregion


