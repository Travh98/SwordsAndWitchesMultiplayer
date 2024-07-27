extends Area3D
class_name LevelTransitionArea

## Tells GameMgr to switch levels when a Player enters this

@export var next_scene: String
@export var target_location: String

signal change_level(new_level: String)
signal enter_area(level_string: String, location: String)

func _ready():
	body_entered.connect(on_body_entered)
	enter_area.connect(GameMgr.enter_area_change_scene)

func on_body_entered(body: Node3D):
	if body.get_node("PlayerController"):
		enter_area.emit(next_scene, target_location)
	
