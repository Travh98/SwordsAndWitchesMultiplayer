extends Node3D

const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

@onready var clientside_grid_placer = $ClientsideGridPlacer

var num_steps: int = 0
var max_steps: int = 200
var steps_since_turn: int = 0
var first_hall_length: int = 6

var current_pos: Vector2 = Vector2.ZERO
var current_dir: Vector2 = Vector2.UP # Negative Y is up
var last_spot: Vector2 = Vector2.ZERO
var step_history: Array[Vector2]
var borders: Rect2 = Rect2(-20, -39, 40, 40)


func _ready():
	pass
	#var my_seed = "balloon"
	#seed(my_seed.hash()) # Hash the seed to a number
	#print("Random num: ", randi_range(0, 210))
	
	## This array is what we will rpc to clients
	#var pos_array: Array[Vector2] = generate_castle()
	#var serialized_array: String
	#for pos in pos_array:
		#serialized_array += "[" + str(pos.x) + "," + str(pos.y) + "]"
	#print("Serialized generation: ", serialized_array)
	#
	#clientside_grid_placer.load_meshes(pos_array)


#func generate_castle() -> Array[Vector2]:
	#step_history.append(current_pos)
	#
	#for step_index in max_steps:
		#if randf() <= 0.25 or steps_since_turn >= 4:
			#if num_steps > first_hall_length:
				#change_direction()
		#
		#if step():
			## Add new pos to step history
			#step_history.append(current_pos)
	#return step_history
#
#
#func step() -> bool:
	#var target_pos = current_pos + current_dir
	#if borders.has_point(target_pos):
		#steps_since_turn += 1
		#num_steps += 1
		#current_pos = target_pos
		#return true
	#else:
		#return false
#
#func change_direction():
	#steps_since_turn = 0
	#var possible_dirs = DIRECTIONS.duplicate()
	#possible_dirs.erase(current_dir)
	#possible_dirs.shuffle()
	#current_dir = possible_dirs.pop_front()
	## Check each new direction until we find one that isnt taken
	#while not borders.has_point(current_pos + current_dir):
		#current_dir = possible_dirs.pop_front()
		#if possible_dirs.is_empty():
			#return
