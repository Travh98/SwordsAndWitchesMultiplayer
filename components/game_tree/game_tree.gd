class_name GameTree
extends Node

## Manages the tree items (UI, Current Level, Camera)


@onready var player_mgr: PlayerMgr = $Players
@onready var gui_mgr: GuiMgr = $GuiMgr

# Level
@onready var current_level: Node3D = $CurrentLevel

var level: Level : get = get_level


func _ready():
	GameMgr.game_tree = self
	
	update_level()
	
	# Connect the tree
	
	Server.change_map.connect(on_map_change)


func _input(_event):
	if Input.is_action_just_pressed("quit_game"):
		get_tree().quit()


func on_name_change(n: String):
	GameMgr.on_name_selected(n)


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
	#await get_tree().create_timer(1).timeout
	#print("Respawning players")
	player_mgr.respawn_players.call_deferred()


