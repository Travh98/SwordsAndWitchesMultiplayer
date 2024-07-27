class_name BloodParticles
extends GPUParticles3D

@onready var animation_player = $AnimationPlayer

func full_blood_fountain():
	animation_player.play("full_blood_fountain")
