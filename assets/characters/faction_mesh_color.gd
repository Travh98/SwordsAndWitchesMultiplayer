class_name FactionMeshColor
extends Node3D

@export var mesh: MeshInstance3D

func set_faction(f: FactionMgr.Factions):
	if mesh == null:
		push_warning("Failed to set faction mesh color on: ", name)
		return
	
	var c: Color = FactionMgr.get_faction_color(f)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = c
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.set_surface_override_material(0, mat)
	
