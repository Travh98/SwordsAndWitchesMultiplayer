class_name HurtBox
extends Area3D

## An area that hurts anything that has HealthComponent when they enter

signal hurtbox_active_changed(a: bool)

@export var damage: int = 0
@export var active: bool = false : set = set_active
var mob_owner: Mob = null : set = set_mob_owner

func _ready():
	body_entered.connect(on_body_entered)


func set_active(a: bool):
	active = a
	hurtbox_active_changed.emit(a)
	if active:
		start_damage()
	else:
		end_damage()


func damage_body(body: Node3D):
	# No friendly fire
	if body is Mob:
		if mob_owner:
			if FactionMgr.get_friendly_factions(mob_owner.faction).has(body.faction):
				return
	
	if body.has_node("HealthComponent"):
		var health_component: HealthComponent = body.get_node("HealthComponent")
		
		if health_component.get_multiplayer_authority() == get_multiplayer_authority():
			print("Server damaging body: ", body.name, " from peer: ", get_multiplayer_authority())
			health_component.take_damage(damage, mob_owner.get_path())
		else:
			health_component.take_damage.rpc(damage, mob_owner.get_path())
			print("Client damaging body: ", body.name, " from peer: ", get_multiplayer_authority())


func on_body_entered(body: Node3D):
	if active:
		damage_body(body)


func start_damage():
	for body in get_overlapping_bodies():
		damage_body(body)


func end_damage():
	# Do nothing
	pass


func set_mob_owner(m: Mob):
	mob_owner = m
