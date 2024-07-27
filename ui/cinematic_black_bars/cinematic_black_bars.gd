class_name CinematicBlackBars
extends Control

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func show_black_bars():
	anim_player.play("show_black_bars")


func hide_black_bars():
	anim_player.play("hide_black_bars")
