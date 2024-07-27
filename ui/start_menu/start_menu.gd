class_name StartMenu
extends Control

signal host_server(port: int)
signal join_server(host_ip: String, port: int)
signal name_selected(name: String)

@onready var name_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/NameEdit
@onready var host_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/HostEdit
@onready var port_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/PortEdit
@onready var join_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/JoinButton
@onready var host_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/HostButton
@onready var settings_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/SettingsButton
@onready var credits_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/CreditsButton
@onready var quit_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/QuitButton

@onready var start_menu_buttons: Control = $MarginContainer
@onready var credits: Control = $Credits

@export var next_scene_name: String = "spiral_cliff_level"


func _ready():
	join_button.pressed.connect(on_join_server)
	host_button.pressed.connect(on_host_server)
	credits_button.pressed.connect(show_credits)
	quit_button.pressed.connect(quit)
	settings_button.disabled = true
	credits.close_credits.connect(on_credits_closed)
	
	# Hide the UI while in start menu
	#UserInterfaceMgr.disable_ui()
	


func on_join_server():
	name_selected.emit(name_edit.text)
	join_server.emit(host_edit.text, port_edit.text.to_int())


func on_host_server():
	name_selected.emit(name_edit.text)
	host_server.emit(port_edit.text.to_int())


func load_next_scene():
	GameMgr.change_scene(next_scene_name)
	#UserInterfaceMgr.enable_ui()
	queue_free()


func show_credits():
	credits.visible = true
	start_menu_buttons.visible = false


func on_credits_closed():
	credits.visible = false
	start_menu_buttons.visible = true


func quit():
	get_tree().quit()
