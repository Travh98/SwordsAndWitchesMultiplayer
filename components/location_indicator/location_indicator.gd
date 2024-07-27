extends Node3D
class_name LocationIndicator

## Shows a location in the editor, but disappears on ready

@onready var mesh: MeshInstance3D = $MeshInstance3D
@export var location_name: String

func _ready():
	mesh.visible = false
