extends Control

## Displays ping

@onready var ping_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/PingLabel

func _ready():
	Server.ping_calculated.connect(on_ping_update)


func on_ping_update(p: float):
	if visible:
		ping_label.text = "Ping: " + str(p)


func toggle_display(do_display: bool):
	visible = do_display
