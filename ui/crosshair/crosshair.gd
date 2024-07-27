class_name Crosshair
extends Control

@onready var interact_label: Label = $InteractionLabel
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	$DamageVignette.modulate = Color(0, 0, 0, 0)


func take_damage():
	anim_player.stop()
	anim_player.play("take_damage")
