extends Node3D

## Receives an array of spots to place tiles on
## Generates those tiles based on neighbors

enum TileType {
	TILE_FOURWAY,
	TILE_THREEWAY,
	TILE_TWOWAY,
	TILE_DEADEND,
}

enum TileRelation {
	REL_FORWARD,
	REL_BACKWARD,
	REL_LEFT,
	REL_RIGHT,
}

const PR_FLOOR = preload("res://assets/castle_meshlib/pr_floor.tscn")
const PR_SKINNY_BRIDGE = preload("res://assets/castle_meshlib/pr_skinny_bridge.tscn")
const PR_T_SECTION = preload("res://assets/castle_meshlib/pr_t_section.tscn")
const PR_DEADEND_CLIFF = preload("res://assets/castle_meshlib/pr_deadend_cliff.tscn")
const PR_CURVE_TWOWAY = preload("res://assets/castle_meshlib/pr_curve_twoway.tscn")

const ROTATIONS: Dictionary = {
	"forward": Vector3.ZERO,
	"backward": Vector3(0, deg_to_rad(-180), 0),
	"left": Vector3(0, deg_to_rad(-90), 0),
	"right": Vector3(0, deg_to_rad(90), 0),
	}

var four_ways: Array[PackedScene]
var three_ways: Array[PackedScene]
var straight_two_ways: Array[PackedScene]
var curved_two_ways: Array[PackedScene]
var dead_ends: Array[PackedScene]

var grid_array: Array[Vector2]
var spot_width: float = 10.0


func _ready():
	# Register all prefabs
	four_ways.append(PR_FLOOR)
	three_ways.append(PR_T_SECTION)
	straight_two_ways.append(PR_SKINNY_BRIDGE)
	curved_two_ways.append(PR_CURVE_TWOWAY)
	dead_ends.append(PR_DEADEND_CLIFF)


func load_meshes(array: Array[Vector2]):
	grid_array = array.duplicate()
	
	for spot in grid_array:
		var neighbors: Array[Vector2] = get_tile_neighbors(spot).duplicate()
		var tile_type: TileType = get_tile_type(spot, neighbors)
		
		var new_rotation: Vector3 = Vector3.ZERO
		var prefab: PackedScene
		match tile_type:
			TileType.TILE_FOURWAY:
				prefab = four_ways.pick_random()
				new_rotation = get_random_rotation()
			TileType.TILE_THREEWAY:
				if neighbors.size() == 3:
					var num_neighbors_with_same_y_val: int = 0
					for neighbor in neighbors:
						if neighbor.y == spot.y:
							num_neighbors_with_same_y_val += 1
					if num_neighbors_with_same_y_val == 2:
						# Two neighbors on the same y-level, therefore the last must be a different y-level
						for neighbor in neighbors:
							if neighbor.x == spot.x:
								# This is the third neighbor
								if is_forward_neighbor(spot, neighbor):
									# Tee is pointing up on the y-axis
									new_rotation = ROTATIONS["left"]
								else:
									new_rotation = ROTATIONS["right"]
					else:
						# Two neighbors on same x-level, so tee is pointing on the x-axis
						for neighbor in neighbors:
							if neighbor.y == spot.y:
								if is_left_neighbor(spot, neighbor):
									new_rotation = ROTATIONS["backward"]
								else:
									# Leave the default forward rotation
									pass
					prefab = three_ways.pick_random()
			TileType.TILE_TWOWAY:
				# Determine if straight two way or curved
				if neighbors.size() == 2:
					var first_relation: TileRelation = get_tile_relation(spot, neighbors[0])
					var second_relation: TileRelation = get_tile_relation(spot, neighbors[1])
					if (first_relation == TileRelation.REL_FORWARD and second_relation == TileRelation.REL_BACKWARD) \
					or (second_relation == TileRelation.REL_FORWARD and first_relation == TileRelation.REL_BACKWARD) \
					or (first_relation == TileRelation.REL_RIGHT and second_relation == TileRelation.REL_LEFT) \
					or (second_relation == TileRelation.REL_RIGHT and first_relation == TileRelation.REL_LEFT):
						# This is a straight two way
						prefab = straight_two_ways.pick_random()
						if is_forward_neighbor(spot, neighbors.front()) or is_backward_neighbor(spot, neighbors.front()):
							pass
						else:
							new_rotation = ROTATIONS["right"]
					else:
						# This is a curved two way
						prefab = curved_two_ways.pick_random()
						
						match first_relation:
							TileRelation.REL_FORWARD:
								if second_relation == TileRelation.REL_RIGHT:
									new_rotation = ROTATIONS["forward"]
								elif second_relation == TileRelation.REL_LEFT:
									new_rotation = ROTATIONS["left"]
							TileRelation.REL_RIGHT:
								if second_relation == TileRelation.REL_FORWARD:
									new_rotation = ROTATIONS["forward"]
								elif second_relation == TileRelation.REL_BACKWARD:
									new_rotation = ROTATIONS["right"]
							TileRelation.REL_BACKWARD:
								if second_relation == TileRelation.REL_RIGHT:
									new_rotation = ROTATIONS["left"]
								elif second_relation == TileRelation.REL_LEFT:
									new_rotation = ROTATIONS["backward"]
							TileRelation.REL_LEFT:
								if second_relation == TileRelation.REL_FORWARD:
									new_rotation = ROTATIONS["left"]
								elif second_relation == TileRelation.REL_BACKWARD:
									new_rotation = ROTATIONS["backward"]
				
			TileType.TILE_DEADEND:
				prefab = dead_ends.pick_random()
				if is_backward_neighbor(spot, neighbors.front()):
					new_rotation = ROTATIONS["backward"]
				elif is_left_neighbor(spot, neighbors.front()):
					new_rotation = ROTATIONS["left"]
				elif is_right_neighbor(spot, neighbors.front()):
					new_rotation = ROTATIONS["right"]
			_:
				prefab = four_ways.pick_random()
		
		var tile: Node3D = prefab.instantiate()
		add_child(tile)
		var tile_xy: Vector2 = spot * spot_width
		tile.position = Vector3(tile_xy.x, 0, tile_xy.y)
		tile.rotation = new_rotation
		print("Tile ", spot, " is a ", TileType.keys()[tile_type], " with ", neighbors.size(), " neighbors.")
		


func get_tile_neighbors(spot: Vector2) -> Array[Vector2]:
	var neighbors: Array[Vector2] = []
	# Look for direct neighbors
	for neighbor in grid_array:
		if is_forward_neighbor(spot, neighbor) or is_backward_neighbor(spot, neighbor) \
		or is_left_neighbor(spot, neighbor) or is_right_neighbor(spot, neighbor):
			# No duplicates
			if neighbors.has(neighbor):
				continue
			neighbors.append(neighbor)
	return neighbors


func get_tile_type(_spot: Vector2, neighbors: Array[Vector2]) -> TileType:
	var num_neighbors: int = neighbors.size()
	match num_neighbors:
		0:
			return TileType.TILE_TWOWAY
		1: 
			return TileType.TILE_DEADEND
		2:
			return TileType.TILE_TWOWAY
		3: 
			return TileType.TILE_THREEWAY
		4:
			return TileType.TILE_FOURWAY
		_:
			push_warning("Too many neighbors!")
	return TileType.TILE_FOURWAY


func is_forward_neighbor(spot: Vector2, neighbor: Vector2) -> bool:
	if neighbor.x == spot.x and neighbor.y == spot.y + 1:
		return true
	return false


func is_backward_neighbor(spot: Vector2, neighbor: Vector2) -> bool:
	if neighbor.x == spot.x and neighbor.y == spot.y - 1:
		return true
	return false


func is_left_neighbor(spot: Vector2, neighbor: Vector2) -> bool:
	if neighbor.y == spot.y and neighbor.x == spot.x - 1:
		return true
	return false


func is_right_neighbor(spot: Vector2, neighbor: Vector2) -> bool:
	if neighbor.y == spot.y and neighbor.x == spot.x + 1:
		return true
	return false


func get_tile_relation(spot: Vector2, relative: Vector2) -> TileRelation:
	if is_forward_neighbor(spot, relative):
		return TileRelation.REL_FORWARD
	elif is_backward_neighbor(spot, relative):
		return TileRelation.REL_BACKWARD
	elif is_left_neighbor(spot, relative):
		return TileRelation.REL_LEFT
	else:
		return TileRelation.REL_RIGHT


func get_random_rotation() -> Vector3:
	return ROTATIONS[ROTATIONS.keys()[randi() % ROTATIONS.size()]]
