extends Control

## Displays frames per second

@onready var fps_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/FpsLabel

func _ready():
	pass


func _process(_delta):
	if visible:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())


func toggle_display(do_display: bool):
	visible = do_display
