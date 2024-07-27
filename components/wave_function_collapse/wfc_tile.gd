extends Resource
class_name WfcTile

#@export var up_neighbors: Array[WfcTile]
#@export var right_neighbors: Array[WfcTile]
#@export var left_neighbors: Array[WfcTile]
#@export var down_neighbors: Array[WfcTile]

#@export var model: PackedScene
#
#func print_info():
	#print(resource_name, " has [", up_neighbors.size(), ",", right_neighbors.size() \
	#, left_neighbors.size(), ",", down_neighbors.size(), "] and model: ", model)
