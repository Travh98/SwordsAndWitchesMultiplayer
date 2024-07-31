class_name Sword
extends HandItem

@onready var animation_player = $AnimationPlayer
@onready var hurt_box: HurtBox = $SwordMesh/IronSword2/HurtBox
@onready var iron_sword_mesh = $SwordMesh/IronSword2
@onready var block_area: BlockArea = $SwordMesh/IronSword2/BlockArea

func _ready():
	grab_node_r = iron_sword_mesh
	grab_node_l = iron_sword_mesh
	hurt_box.weapon_owner = self
	block_area.weapon_owner = self


func primary_use():
	super()
	if animation_player.is_playing():
		return
	animation_player.play("swing1")


func secondary_use():
	if animation_player.is_playing():
		return
	animation_player.play("parry")


func alt1_use():
	super()
	if animation_player.is_playing():
		return
	animation_player.play("down_swing")


func alt2_use():
	super()
	if animation_player.is_playing():
		return
	animation_player.play("stab")


func register_user(user: Mob):
	super(user)
	hurt_box.set_mob_owner(user)
	set_multiplayer_authority(user.get_multiplayer_authority())


func get_parried():
	cancel_animation()
	animation_player.play("parried")


func long_spiral_block():
	if animation_player.is_playing():
		return
	animation_player.play("long_spiral_block")


func successful_parry():
	cancel_animation()


func cancel_animation():
	if block_area.monitoring:
		block_area.set_deferred("monitoring", false) # Manual setting gets blocked during in/out signal
	hurt_box.active = false
	animation_player.stop()
	
