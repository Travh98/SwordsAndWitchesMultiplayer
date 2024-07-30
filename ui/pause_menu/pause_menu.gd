class_name PauseMenu
extends Control

signal disconnect()
signal change_name(new_name: String)

@onready var name_select_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/NameSelectEdit
@onready var name_apply_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/NameApplyButton
@onready var disconnect_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/DisconnectButton
@onready var your_name: Label = $MarginContainer/HBoxContainer/VBoxContainer/YourName


func _ready():
	name_apply_button.pressed.connect(on_apply_name)
	disconnect_button.pressed.connect(on_disconnect)


func on_apply_name():
	if GameMgr.is_valid_name(name_select_edit.text):
		change_name.emit(name_select_edit.text)


func on_disconnect():
	disconnect.emit()


func update_name(new_name: String):
	your_name.text = new_name
