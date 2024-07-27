class_name TwoPanelDoor
extends Area3D

@export var other_panel: TwoPanelDoor
@export var is_open: bool = false
@export var anim_time: float = 0.5
@export var hinge_rotate_deg: float = 90

func on_interact():
	var tween: Tween = get_tree().create_tween()
	if is_open:
		# Close the door
		tween.tween_property(self, "rotation", Vector3.ZERO, anim_time)
		
		# Also close the other panel if it matches our state
		if other_panel != null:
			if other_panel.is_open:
				other_panel.on_interact()
	else:
		# Open the door
		tween.tween_property(self, "rotation", Vector3(0, deg_to_rad(hinge_rotate_deg), 0), anim_time)
		
		# Also open the other panel if it matches our state
		if other_panel != null:
			if !other_panel.is_open:
				other_panel.on_interact()
	
	is_open = !is_open
