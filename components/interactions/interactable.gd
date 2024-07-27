class_name Interactable
extends Node3D

signal value_changed(value: int)

@export var value: int = 0

@onready var interact_area: InteractArea = $InteractArea

func _ready():
	interact_area.do_interact.connect(do_interact)


func do_interact():
	pass
