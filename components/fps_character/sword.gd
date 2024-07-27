extends HandItem

@onready var animation_player = $AnimationPlayer
@onready var hurt_box: HurtBox = $SwordMesh/IronSword2/HurtBox
@onready var iron_sword_mesh = $SwordMesh/IronSword2

func _ready():
	grab_node_r = iron_sword_mesh
	grab_node_l = iron_sword_mesh


func primary_use():
	super()
	if animation_player.is_playing():
		return
	animation_player.play("swing1")


func secondary_use():
	print("block")
	pass


func alt1_use():
	super()
	if animation_player.is_playing():
		return
	animation_player.play("down_swing")


func alt2_use():
	super()
	if animation_player.is_playing():
		return
	animation_player.play("test_hold_swing")


func register_user(user: Mob):
	super(user)
	hurt_box.set_mob_owner(user)
	set_multiplayer_authority(user.get_multiplayer_authority())
	
