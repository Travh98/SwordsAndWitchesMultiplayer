class_name HudHealthbar
extends Control

@onready var hp_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/HpLabel
@onready var healthbar: ProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/Healthbar
@onready var speed_label = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/SpeedLabel
var health_component: HealthComponent

func _ready():
	pass


func assign_health_component(h: HealthComponent):
	if h:
		health_component = h
		health_component.health_changed.connect(on_health_changed)
	else:
		if health_component:
			health_component.health_changed.disconnect(on_health_changed)
			health_component = null


func on_health_changed(new_health: int):
	hp_label.text = "hp: " + str(health_component.health) + " / " + str(health_component.max_health)
	healthbar.value = new_health


func speed_updated(new_speed: float):
	speed_label.text = "speed: " + str(new_speed).pad_decimals(2) + " m/s"
