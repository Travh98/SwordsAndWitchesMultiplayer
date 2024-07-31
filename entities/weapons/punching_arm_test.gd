extends HandItem

@onready var animation_player = $AnimationPlayer
@onready var right_fist: Node3D = $RightFist
@onready var left_fist: Node3D = $LeftFist

@onready var right_hurt_box: HurtBox = $RightFist/RightHurtBox
@onready var left_hurt_box: HurtBox = $LeftFist/LeftHurtBox

var left_punch: bool = false


func _ready():
	grab_node_r = right_fist
	grab_node_l = left_fist
	right_hurt_box.weapon_owner = self
	left_hurt_box.weapon_owner = self


func primary_use():
	super()
	if animation_player.is_playing():
		return
	if !left_punch:
		animation_player.play("right_punch")
	else:
		animation_player.play("left_punch")
	left_punch = !left_punch


func register_user(user: Mob):
	super(user)
	right_hurt_box.set_mob_owner(user)
	left_hurt_box.set_mob_owner(user)
