class_name MuzzleFlash
extends Node3D

const BULLET_TRAIL = preload("res://components/muzzle_flashes/bullet_trail.tscn")
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var bullet_trail_distance_cast: RayCast3D = $BulletTrailDistanceCast
@onready var muzzle_light: SpotLight3D = $MuzzleLight

const AliveTime: float = 0.02

func _ready():
	muzzle_light.visible = false
	pass


func on_fire():
	particles.emitting = true
	
	muzzle_light.visible = true
	
	var bullet_trail = BULLET_TRAIL.instantiate()
	get_tree().root.add_child(bullet_trail)
	bullet_trail.global_position = global_position
	bullet_trail.global_rotation = global_rotation
	
	bullet_trail_distance_cast.force_raycast_update()
	if bullet_trail_distance_cast.is_colliding():
		bullet_trail.max_distance = global_position.distance_to(bullet_trail_distance_cast.get_collision_point())
	
	await get_tree().create_timer(AliveTime).timeout
	muzzle_light.visible = false
