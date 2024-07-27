extends Control

## Global Autoload Manager for User Interface

@onready var hud: Control = $Hud
@onready var pause_menu: Control = $PauseMenu

@onready var cinematic_black_bars: CinematicBlackBars = $Hud/CinematicBlackBars
@onready var fade_to_black_ui: FadeToBlack = $FadeToBlack

var is_paused: bool = false


func _ready():
	fade_to_black_ui.fade_from_black()
	cinematic_black_bars.hide_black_bars()


func _input(_event):
	if Input.is_action_just_pressed(&"menu"):
		if is_paused:
			unpause_game()
		else:
			# Don't pause the game if we're not supposed to be processing (Dialog or cutscenes)
			if GameMgr.do_process_actions:
				pause_game()


func pause_game():
	pause_menu.visible = true
	hud.visible = false
	GameMgr.set_process_actions(false)
	
	is_paused = true


func unpause_game():
	pause_menu.visible = false
	hud.visible = true
	GameMgr.set_process_actions(true)
	
	is_paused = false


func enable_ui():
	visible = true


func disable_ui():
	visible = false


func show_cinematic_black_bars():
	cinematic_black_bars.show_black_bars()


func hide_cinematic_black_bars():
	cinematic_black_bars.hide_black_bars()


func fade_to_black():
	fade_to_black_ui.fade_to_black()


func fade_from_black():
	fade_to_black_ui.fade_from_black()
