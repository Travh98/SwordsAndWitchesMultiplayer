extends Node

## Singleton for managing the game

signal name_changed(new_name: String)

# The current scene that owns the game and is a child of root
var current_game_scene: Node
var current_level_parent: Node

# Global boolean for pausing anything important, while allowing animations to play
var game_paused: bool = false

# This client's info
var game_tree: GameTree
var player_name: String : set = on_name_selected


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# We will spawn levels as a child of this node
	current_level_parent = get_tree().root.get_node("GameTree/CurrentLevel")
	
	set_random_name()
	
	deferred_init.call_deferred()


func deferred_init():
	if !game_tree:
		push_error("NO GAME TREE")
	
	game_paused = false
	game_tree.pause_menu.visible = false


func _input(_event):
	if Input.is_action_just_pressed("pause"):
		if game_paused:
			unpause_game()
		else:
			pause_game()


func pause_game():
	game_tree.pause_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_paused = true


func unpause_game():
	game_tree.pause_menu.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	game_paused = false


func change_scene(level_name: String) -> bool:
	var next_scene_path = "res://levels/" + level_name + ".tscn"
	if FileAccess.file_exists(next_scene_path):
		#print("Changing scene to: ", level_name)
		
		# Load the new scene
		var NewLevel: PackedScene = load(next_scene_path)
		var new_level: Node3D = NewLevel.instantiate()
		
		# Remove existing scene
		for level in current_level_parent.get_children():
			level.queue_free.call_deferred()
		current_game_scene = new_level
		
		current_level_parent.add_child.call_deferred(new_level)
		return true
	else:
		push_warning("Could not find scene to transition to: ", next_scene_path)
		return false


### Utilities ###

func GetAllTreeNodes(node = get_tree().root, listOfAllNodesInTree = []):
	listOfAllNodesInTree.append(node)
	for childNode in node.get_children():
		GetAllTreeNodes(childNode, listOfAllNodesInTree)
	return listOfAllNodesInTree


func print_root_children():
	for child in get_tree().root.get_children():
		print("Tree root child: ", child)


func set_random_name():
	var default_names = ["beef cake", "butterscotch", "princess", "good smelling", "dough nuts", "dandelion", "spooky face", "creeper", "candy corn", "musketeer", "wizard", "trick or treat", "candy", "biscuit", "lollypop", "chocolate chip"]
	var n: String = default_names.pick_random() + " [" + str(Time.get_datetime_dict_from_system()["second"]) + "]"
	on_name_selected(n)


func on_name_selected(n: String):
	if n.is_empty():
		#print("Selected name is empty, defaulting to: ", player_name)
		name_changed.emit(player_name)
		return
	player_name = n
	#print("Setting name to: ", player_name, " for client: ", str(get_multiplayer_authority()))
	name_changed.emit(player_name)
