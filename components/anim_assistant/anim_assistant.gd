extends Node

## A non-autoload node that allows AnimPlayers to call Autoload functions
## and spawn entities


func start_dialog(dialog_timeline: String):
	# Check if a dialog is already running
	if Dialogic.current_timeline != null:
		return
	
	Dialogic.start(dialog_timeline)


#func fade_from_black():
	#UserInterfaceMgr.fade_from_black()
#
#
#func fade_to_black():
	#UserInterfaceMgr.fade_to_black()
#
#
#func hide_cinematic_bars():
	#UserInterfaceMgr.hide_cinematic_black_bars()
#
#
#func show_cinematic_bars():
	#UserInterfaceMgr.show_cinematic_black_bars()
