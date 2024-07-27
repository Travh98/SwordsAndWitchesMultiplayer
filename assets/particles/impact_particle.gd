extends GPUParticles3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	anim_player.play("impact_particle")
