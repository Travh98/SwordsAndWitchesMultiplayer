extends HandItem

@onready var animation_player = $AnimationPlayer
@onready var hurt_box: HurtBox = $MeshInstance3D/HurtBox

var left_punch: bool = false


func primary_use():
	super()
	if animation_player.is_playing():
		return
	if !left_punch:
		animation_player.play("punch")
	else:
		animation_player.play("punch2")
	left_punch = !left_punch


func register_user(user: Mob):
	super(user)
	hurt_box.set_mob_owner(user)
