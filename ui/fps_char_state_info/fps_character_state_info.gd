extends Control
class_name FpsCharacterStateInfo

@onready var units_per_second: Label = $MarginContainer/VBoxContainer/UnitsPerSecond
@onready var state_label: Label = $MarginContainer/VBoxContainer/StateLabel


func set_speed(speed: float):
	units_per_second.text = "<" + str(speed).pad_decimals(2) + " ups>"


func set_state(state_str: String):
	state_label.text  = state_str
