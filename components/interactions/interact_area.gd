extends Area3D
class_name InteractArea

## Area that emits a signal to the item you are trying to interact with
## when the interact_controller hits this with a interact raycast

signal do_interact()

func on_interact():
	do_interact.emit()
