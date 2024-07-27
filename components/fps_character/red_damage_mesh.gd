extends Node3D

@onready var hurt_box: HurtBox = $HurtBox
var mesh: MeshInstance3D

func _ready():
	hurt_box.hurtbox_active_changed.connect(update_active_color)
	
	for child in get_children():
		if child is MeshInstance3D:
			mesh = child


func update_active_color(a: bool):
	if a:
		set_mesh_color(Color.RED)
	else:
		set_mesh_color(Color.WHITE)


func set_mesh_color(c: Color):
	if !mesh:
		return
	var material: StandardMaterial3D = mesh.get_active_material(0)
	if material:
		material.albedo_color = c
		
