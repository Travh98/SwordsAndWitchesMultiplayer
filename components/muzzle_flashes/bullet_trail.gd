extends Node3D

## Moves bullet trail mesh until it despawns
## https://www.youtube.com/watch?v=WoWlaB95Rzs

@onready var mesh_instance_3d = $MeshInstance3D
var trail_mesh_height: float
@onready var lifetime: float = 1
var max_distance: float = 0
var speed = 100

func _ready():
	trail_mesh_height = mesh_instance_3d.mesh.height / 2
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _process(delta):
	mesh_instance_3d.position += Vector3.FORWARD * speed * delta
	
	if max_distance > 0:
		if global_position.distance_to(mesh_instance_3d.global_position) >= max_distance - trail_mesh_height:
			queue_free()
