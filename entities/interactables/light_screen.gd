class_name LightScreen
extends StaticBody3D

@export var interactable: Interactable
@onready var material: StandardMaterial3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@export var value: int = 0

func _ready():
	# Mesh and Mesh's material both have to be local to scene
	material = mesh_instance_3d.mesh.surface_get_material(0)
	if interactable:
		if !interactable.is_node_ready():
			await interactable.ready
		interactable.value_changed.connect(on_state_change)
		set_screen(interactable.value)
	else:
		set_screen(value)
		print("No interactable for Light Screen")


func on_state_change(state: int):
	value = state
	set_screen(value)
	#print(name, " value: ", value)


func set_screen(v: int):
	match v:
		0:
			set_color(Color.RED)
		1:
			set_color(Color.YELLOW)


func set_color(color: Color):
	material.albedo_color = color
	material.emission = color
