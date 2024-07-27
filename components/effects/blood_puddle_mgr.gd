extends Node3D

const BLOOD_PUDDLE: PackedScene = preload("res://assets/effects/blood_puddle.tscn")
const BLOOD_PARTICLES: PackedScene = preload("res://assets/effects/blood_particles.tscn")
@onready var mob: Node3D = get_parent()
var health_component: HealthComponent


func _ready():
	if mob.has_node("HealthComponent"):
		health_component = mob.get_node("HealthComponent")
		health_component.damaged_by.connect(on_damaged_by)
	else:
		push_warning("No Health Component for BloodPuddleMgr on mob: ", mob.name)


func on_damaged_by(_m: Mob):
	if health_component.is_dead:
		return
	start_bleeding(global_position + Vector3.UP)


func start_bleeding(global_bleed_spot: Vector3):
	var blood_particles: BloodParticles = BLOOD_PARTICLES.instantiate()
	add_child(blood_particles)
	blood_particles.position = to_local(global_bleed_spot)
	blood_particles.full_blood_fountain()
	
	var blood_puddle: Node3D = BLOOD_PUDDLE.instantiate()
	get_tree().root.add_child(blood_puddle)
	blood_puddle.global_position = mob.global_position
