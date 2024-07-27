class_name MeleeAttackState
extends State

# Components this state needs
@onready var mob: Mob
@onready var nav_agent: NavigationAgent3D = $"../../NavigationAgent3D"
@onready var timeout_timer: Timer = $TimeoutTimer

# Variables for this state
@export var prepare_time: float = 0.5
@export var attack_time: float = 0.2
@export var recover_time: float = 0.5
var combat_target: Mob

enum MeleeAttackStages
{
	STAGE_PREPARE,
	STAGE_ATTACK,
	STAGE_RECOVER,
	STAGE_FINISHED
}
var stage: MeleeAttackStages = MeleeAttackStages.STAGE_PREPARE
var anim_player: AnimationPlayer
var is_attack_finished: bool = false


func _ready():
	timeout_timer.one_shot = true


func _enter_state():
	timeout_timer.start()
	stage = MeleeAttackStages.STAGE_PREPARE
	is_attack_finished = false
	
	if weakref(mob).get_ref():
		mob.direction = Vector3.ZERO


func _state_logic(delta: float):
	if get_parent().combat_target != null:
		mob.rotate_towards_position(get_parent().combat_target.global_position, delta)
	
	if mob.has_node("EquipmentSlots"):
		mob.get_node("EquipmentSlots").use("Primary Hand")
	
	match stage:
		MeleeAttackStages.STAGE_PREPARE:
			if anim_player.current_animation != "pre_melee_attack" || not anim_player.is_playing():
				anim_player.play("pre_melee_attack")
			if timeout_timer.time_left <= 0:
				stage = MeleeAttackStages.STAGE_ATTACK
				timeout_timer.wait_time = attack_time
				timeout_timer.start()
		MeleeAttackStages.STAGE_ATTACK:
			if anim_player.current_animation != "melee_attack" || not anim_player.is_playing():
				anim_player.play("melee_attack")
			if timeout_timer.time_left <= 0:
				stage = MeleeAttackStages.STAGE_RECOVER
				timeout_timer.wait_time = recover_time
				timeout_timer.start()
		MeleeAttackStages.STAGE_RECOVER:
			if anim_player.current_animation != "post_melee_attack" || not anim_player.is_playing():
				anim_player.play("post_melee_attack")
			if timeout_timer.time_left <= 0:
				stage = MeleeAttackStages.STAGE_FINISHED
				timeout_timer.wait_time = recover_time
				timeout_timer.start()
		MeleeAttackStages.STAGE_FINISHED:
			if timeout_timer.time_left <= 0:
				is_attack_finished = true


func _exit_state():
	pass



