class_name HurtBox
extends Area3D

## An area that hurts anything that has HealthComponent when they enter

signal hurtbox_active_changed(a: bool)

@export var damage: int = 0
@export var active: bool = false : set = set_active
var mob_owner: Mob = null : set = set_mob_owner
var weapon_owner: HandItem = null : set = set_weapon_owner
var hit_objects = []

func _ready():
	body_entered.connect(on_body_entered)


func set_active(a: bool):
	active = a
	hurtbox_active_changed.emit(a)
	if active:
		start_damage.call_deferred()
	else:
		end_damage()


func damage_body(body: Node3D):
	# Only hit things once per attack
	if hit_objects.has(body):
		return
	
	# No friendly fire
	if body is Mob:
		if mob_owner:
			if FactionMgr.get_friendly_factions(mob_owner.faction).has(body.faction):
				return
	
	# Don't hit yourself
	if body == mob_owner:
		return
	
	if body.has_node("HealthComponent"):
		hit_objects.append(body)
		Server.damage_entity.rpc_id(1, mob_owner.name.to_int(), body.name.to_int(), damage)


func on_body_entered(body: Node3D):
	if !is_multiplayer_authority(): return
	if active:
		damage_body(body)


func start_damage():
	if !is_multiplayer_authority(): return
	for body in get_overlapping_bodies():
		damage_body(body)


func end_damage():
	# Do nothing
	hit_objects.clear()
	pass


func set_mob_owner(m: Mob):
	mob_owner = m
	set_multiplayer_authority(mob_owner.get_multiplayer_authority())


func set_weapon_owner(w: HandItem):
	weapon_owner = w
