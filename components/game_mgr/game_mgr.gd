extends Node

## Singleton for managing the game

# The current scene that owns the game and is a child of root
var current_game_scene: Node
var current_level_parent: Node

# Global boolean for pausing anything important, while allowing animations to play
var game_paused: bool = false

# This client's info
var game_tree: GameTree


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	game_paused = false
	


func _input(_event):
	if Input.is_action_just_pressed("pause"):
		if game_paused:
			unpause_game()
		else:
			pause_game()
	
	if Input.is_action_just_pressed("quit_game"):
		get_tree().quit()


func pause_game():
	game_tree.gui_mgr.pause_menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_paused = true


func unpause_game():
	game_tree.gui_mgr.pause_menu.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	game_paused = false
