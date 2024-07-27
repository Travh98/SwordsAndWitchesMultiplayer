extends Area3D
class_name BloodPuddle

@onready var anim_player: AnimationPlayer = $AnimationPlayer


func wash_away():
	anim_player.play("wash_away")
