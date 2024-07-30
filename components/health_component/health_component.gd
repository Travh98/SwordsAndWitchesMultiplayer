class_name HealthComponent
extends Node

## A component for managing Health

signal health_changed(health_value: int)
signal health_died
signal damaged_by(damager: Node3D)

@export var health: int = 100
@export var max_health: int = 100

var invincible: bool = false
var is_dead: bool = false
var last_damaged_by: Mob = null


func _ready():
	pass


@rpc("any_peer", "call_remote", "reliable")
func take_damage(damage: int, damager_path: NodePath = ""):
	if invincible:
		return
	print(get_parent().name, " took damage from nodepath: ", damager_path, " and is owned by: ", get_multiplayer_authority())
	if has_node(damager_path):
		var damager: Node3D = get_node(damager_path)
		if damager:
			last_damaged_by = damager
			damaged_by.emit(damager)
	_update_health(get_health() - damage)


func get_health() -> int:
	return health


@rpc("any_peer", "call_local", "reliable")
func full_heal():
	_update_health(max_health)


func _update_health(new_health: int):
	if new_health > max_health:
		health = max_health
	else:
		health = new_health
	health_changed.emit(health)
	
	if new_health > 0:
		is_dead = false
	
	if new_health <= 0 and not is_dead:
		health_died.emit()
		is_dead = true
		if last_damaged_by:
			print(get_parent().name, " killed by ", last_damaged_by.name)
