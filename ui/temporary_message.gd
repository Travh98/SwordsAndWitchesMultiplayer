class_name TemporaryMessage
extends Control

@onready var temp_msg_label: RichTextLabel = $HBoxContainer/VBoxContainer/TempMsgLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	temp_msg_label.modulate = Color.TRANSPARENT


func set_temporary_message(new_message: String):
	animation_player.stop()
	temp_msg_label.text = "[font_size=24][center]%s[/center][/font_size]" % [new_message]
	animation_player.play("display_msg")
