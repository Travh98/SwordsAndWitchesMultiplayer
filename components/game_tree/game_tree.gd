class_name GameTree
extends Node

## Manages the tree items

@onready var player_mgr: PlayerMgr = $Players
@onready var player_data_mgr: PlayerDataMgr = $PlayerDataMgr
@onready var gui_mgr: GuiMgr = $GuiMgr
@onready var level_mgr: LevelMgr = $LevelMgr
@onready var camera: Camera3D = $Camera3D


func _ready():
	GameMgr.game_tree = self
	
	level_mgr.new_map_loaded.connect(player_mgr.on_new_map_loaded)
	player_mgr.respawn_player.connect(level_mgr.respawn_entity)
	
	gui_mgr.local_player_name_changed.connect(player_data_mgr.on_local_player_name_changed)
	player_data_mgr.player_name_changed.connect(player_mgr.update_player_name)
	
	# Store incoming player data
	Server.player_name_changed.connect(player_data_mgr.on_player_name_changed)
	Server.server_connection_changed.connect(player_data_mgr.on_server_connection_changed)
	Server.player_data_received.connect(player_data_mgr.receive_player_data)
	
	player_data_mgr.player_active_inv_slot_changed.connect(player_mgr.on_player_equipment_changed)
	player_data_mgr.player_health_changed.connect(player_mgr.on_player_health_changed)
	player_data_mgr.player_hat_selected.connect(player_mgr.on_player_hat_selected)

