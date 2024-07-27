extends Control

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar

func _ready():
	anim_player.play("spin_loading")

