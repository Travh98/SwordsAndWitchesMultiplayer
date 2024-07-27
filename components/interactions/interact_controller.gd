extends Node

## Controls a raycast to allow players to interact with anything that has
## the on_interact function

@export var interact_cast: RayCast3D
@export var interact_range: float = 6

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		if interact_cast == null:
			push_warning("Missing interact cast for ", get_parent().name)
			return
		
		var hit_object = interact_cast.get_collider()
		if hit_object != null:
			if interact_cast.global_position.distance_to(hit_object.global_position) > interact_range:
				print("Tried interacting but object is too far: ", hit_object)
				return
			
			if hit_object.has_method("on_interact"):
				hit_object.on_interact()
				print("Interacting with ", hit_object)
