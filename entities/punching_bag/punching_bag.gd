extends RigidBody3D

## A punching bag that can take damage

@onready var health_component: HealthComponent = $HealthComponent
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	health_component.health_changed.connect(on_health_changed)
	health_component.health_died.connect(on_death)


func on_health_changed(_hp: int):
	anim_player.play("red_damage")


func on_death():
	queue_free()
