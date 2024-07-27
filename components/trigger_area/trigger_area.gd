class_name TriggerArea
extends Area3D

## This area emits a triggered signal anytime something enters it

signal triggered()

@export var trigger_once: bool = false

func _ready():
	body_entered.connect(on_body_entered)


func on_body_entered(_body: Node3D):
	triggered.emit()
	
	if trigger_once:
		call_deferred("queue_free")
