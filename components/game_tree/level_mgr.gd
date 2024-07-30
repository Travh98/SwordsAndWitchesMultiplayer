class_name LevelMgr
extends Node

## Manages the current level

signal new_map_loaded(map_name: String)

var level: Level : set = set_level
var map_name: String = ""
var tile_array: Array[Vector2] = []


func _ready():
	set_level(get_children().front())
	Server.change_map.connect(on_map_change)
	Server.level_gen_tiles_received.connect(on_level_gen_tiles_received)


func on_map_change(new_map_name: String):
	var new_map_path: String = "res://levels/" + new_map_name + ".tscn"
	if !ResourceLoader.exists(new_map_path):
		push_warning("Missing map: ", new_map_path)
		return
	
	var new_map: Node = load(new_map_path).instantiate()
	if !new_map:
		push_warning("Error loading map: ", new_map_path)
		return
	
	map_name = new_map_name
	
	set_level(new_map)
	
	new_map_loaded.emit(map_name)
	
	#await get_tree().create_timer(2).timeout
	
	if get_grid_placer():
		get_grid_placer().load_meshes.call_deferred(tile_array)
	
	print("Map Loaded: ", map_name)


func set_level(new_level: Level):
	if new_level == null:
		push_warning("Tried setting level to invalid object!")
		return
	if new_level == level:
		push_warning("Tried setting level but the same level is already loaded: ", map_name)
		return
	
	# Remove instantly to prevent having the old level linger in the tree, messing up the rename
	if level:
		remove_child(level) 
		level.queue_free()
	
	if new_level.get_parent() != self:
		add_child(new_level)
	
	level = new_level
	level.name = "Level"
	
	if level is Level or level != null:
		pass
	else:
		push_warning("Loaded non-Level node as a Level: ", map_name)
	
	#if level != get_children().front():
		#push_warning("Improper setting of level, is not the first child of LevelMgr.")


func respawn_entity(p: Node):
	level.respawn_entity(p)


# Deserialize and store tiles
func on_level_gen_tiles_received(tiles_str: String):
	print("Received serialized tile array of length: ", tiles_str.length())
	tile_array.clear()
	
	var grid_placer: CastleGridPlacer = get_grid_placer()
	if !grid_placer:
		return
	
	var split_tiles: PackedStringArray = tiles_str.split(",", false)
	for tile in split_tiles:
		var tile_index = grid_placer.str_to_vec2(tile)
		tile_array.append(tile_index)
	
	if get_grid_placer():
		get_grid_placer().load_meshes.call_deferred(tile_array)


func get_grid_placer() -> CastleGridPlacer:
	if !level.has_node("CastleGrid/ClientsideGridPlacer"):
		#print("No CastleGridPlacer in this level")
		return null
	return level.get_node("CastleGrid/ClientsideGridPlacer")
