extends Control
class_name FadeToBlack

@onready var anim_player: AnimationPlayer = $AnimationPlayer


func fade_to_black():
	anim_player.play("fade_to_black")


func fade_from_black():
	anim_player.play("fade_from_black")
