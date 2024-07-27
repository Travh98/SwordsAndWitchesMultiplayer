extends Area3D
class_name PlayerTrigger

## This area emits a signal when the player enters it

signal trigger_activated()

func _ready():
	body_entered.connect(on_body_entered)


func on_body_entered(body: Node3D):
	if body.has_node("PlayerController"):
		trigger_activated.emit()
		#print("Player trigger activated!")
