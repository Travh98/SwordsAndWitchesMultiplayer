extends Node3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var explosion_area: Area3D = $ExplodeArea
@export var damage: int = 45
@export var phys_force: int = 5

func _ready():
	anim_player.play("explode")
	

func register_explosion():
	for n in explosion_area.get_overlapping_bodies():
		if n.has_node("HealthComponent"):
			var hp: HealthComponent = n.get_node("HealthComponent")
			hp.take_damage(damage)
#			print(n, " is in explosion, taking damage")
		if n is RigidBody3D:
			n.apply_central_impulse(global_position.direction_to(n.global_position) * phys_force)
		if n is PhysicalBone3D:
			n.apply_central_impulse(global_position.direction_to(n.global_position) * phys_force)
