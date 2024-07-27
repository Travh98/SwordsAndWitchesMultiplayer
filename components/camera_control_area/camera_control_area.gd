extends Area3D

## Changes a PhantomCamera's priority as the player enters or leaves this area

@export var target_pcam: PhantomCamera3D


func _ready():
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)


func on_body_entered(body: Node3D):
	if body.get_node("PlayerController"):
		target_pcam.set_priority(target_pcam.get_priority() + 1)


func on_body_exited(body: Node3D):
	if body.get_node("PlayerController"):
		target_pcam.set_priority(target_pcam.get_priority() - 1)
