extends Node3D

# The higher the number, the longer it takes for the leg to move to the step target
@export var offset: float = 3

@onready var parent = get_parent_node_3d()
@onready var previous_position = parent.global_position


func _ready():
	top_level = false


func _process(_delta):
	# Keep the Step Targets some distance in front of the body
	#var velocity = parent.global_position - previous_position
	#global_position = parent.global_position + velocity * offset
	#global_rotation = parent.global_rotation
	#
	#previous_position = parent.global_position
	pass
