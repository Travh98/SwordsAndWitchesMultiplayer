extends Node3D


@onready var SEA_SPLASH: PackedScene = preload("res://assets/effects/sea_splash.tscn")

@onready var timer: Timer = $Timer
@export var wait_time: float = 3.0
@export var wait_variance: float = 0.25
@export var splash_scale: float = 15.0

func _ready():
	timer.timeout.connect(spawn_splash)



func spawn_splash():
	var splash: Node3D = SEA_SPLASH.instantiate()
	get_tree().root.add_child(splash)
	splash.global_position = global_position
	splash.scale = Vector3.ONE * randf_range(splash_scale - 0.5, splash_scale + 0.5)
	
	timer.wait_time = wait_time + randf_range(-wait_variance, wait_variance)
	timer.start()

