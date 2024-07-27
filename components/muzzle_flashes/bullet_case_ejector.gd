class_name BulletCaseEjector
extends Node3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

func on_fire():
	gpu_particles_3d.restart()
	gpu_particles_3d.emitting = true
