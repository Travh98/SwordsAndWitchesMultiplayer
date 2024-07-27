extends Control

signal close_credits

@onready var godot_version: Label = $MarginContainer/ScrollContainer/CreditsContainer/GodotCredits
@onready var addon_credits: VBoxContainer = $MarginContainer/ScrollContainer/CreditsContainer/AddonCredits
@onready var return_button: Button = $MarginContainer/ScrollContainer/CreditsContainer/ReturnButton

func _ready():
	return_button.pressed.connect(on_exit_credits)
	
	addons_credits()
	
	godot_version.text = "Made with the Godot Engine " + Engine.get_version_info()["string"]


func on_exit_credits():
	visible = false
	close_credits.emit()


func addons_credits():
	# Fill the Addon Credits section
	
	for child in addon_credits.get_children():
		child.queue_free()
	
	# Scan each Addon's plugin.cfg file
	var dir = DirAccess.open("res://addons/")
	if dir:
		dir.list_dir_begin()
		var addon_filename = dir.get_next()
		while addon_filename != "":
			if dir.current_is_dir():
				if dir.file_exists("res://addons/" + addon_filename + "/plugin.cfg"):
					var plugin_file = FileAccess.open("res://addons/" + addon_filename + "/plugin.cfg", FileAccess.READ)
					var addon_info_str: String = ""
					
					if plugin_file:
						while not plugin_file.eof_reached():
							var line = plugin_file.get_line()
							line += " "
							
							if line.contains("name"):
								addon_info_str += line.replace("name=", "").replace("\"", "").replace("\n", "")
							if line.contains("author"):
								addon_info_str += "by " + line.replace("author=", "").replace("\"", "").replace("\n", "")
						plugin_file.close()
					
					if !addon_info_str.is_empty():
						add_addon_credit(addon_info_str)
			addon_filename = dir.get_next()


func add_addon_credit(addon_info: String):
	var credit: Label = Label.new()
	credit.text = addon_info
	credit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	addon_credits.add_child(credit)
