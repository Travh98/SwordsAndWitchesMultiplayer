extends Node

## Written with the help of Garnet's tutorial: https://www.youtube.com/watch?v=iJ_GnGD5BZA&t=8s


@export var dimensions: int = 20
@export var cell_spacing: float = 4.0
@export var tile_objects: Array[WfcTile]
var grid_cells: Array[WfcCell]
@export var CellScene: PackedScene

func _ready():
	scan_for_tiles()
	
	initialize_grid()


func scan_for_tiles():
	var dir = DirAccess.open("res://assets/wave_function_collapse_test/wfc_tiles/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				# This is a file
				var file_path: String = dir.get_current_dir() + "/" + file_name
				print("Found Wave Function Collapse tile: ", file_path)
				tile_objects.append(load(file_path))
			file_name = dir.get_next()
	print("Loaded ", tile_objects.size(), " tile objects")


func initialize_grid():
	for y in range(0, dimensions):
		for x in range(0, dimensions):
			var new_cell: WfcCell = CellScene.instantiate()
			add_child(new_cell)
			new_cell.position = Vector3(x * cell_spacing, 0, y * cell_spacing)
			new_cell.create_cell(false, tile_objects)
			grid_cells.append(new_cell)
	
	# Since we depend on the result of this function, we await for it
	# This function is a coroutine from c#
	await check_entropy()


func check_entropy():
	# Sort the grid so that the first item is the one with the lowest entropy
	# aka the cell that has the least options
	var temp_grid: Array[WfcCell] = grid_cells
	
	# Remove all already collapsed cells
	for cell_index in range(temp_grid.size()):
		var cell: WfcCell = temp_grid[cell_index]
		if cell.is_collapsed:
			temp_grid.remove_at(cell_index)
			cell_index -= 1
	
	temp_grid.sort_custom(custom_sort_cells)
	
	# Remove all cells that don't have the same number of options as the lowest-entropy cell
	for cell_index in range(temp_grid.size()):
		var cell: WfcCell = temp_grid[cell_index]
		if cell.tile_options.size() != temp_grid[0].tile_options.size():
			temp_grid.remove_at(cell_index)
			cell_index -= 1
	
	await get_tree().create_timer(0.125)
	
	collapse_cell(temp_grid)


func custom_sort_cells(a: WfcCell, b: WfcCell):
	return a.tile_options.size() < b.tile_options.size()


func collapse_cell(temp_grid: Array[WfcCell]):
	# Collapse one cell out of this temporary grid of low-entropy cells
	
	# Put the tile into this cell's position
	var rand_index: int = randi_range(0, temp_grid.size())
	
	var cell_to_collapse: WfcCell = temp_grid[rand_index]
	cell_to_collapse.is_collapsed = true
	
	# Randomly chose one of the cell's tile options
	var rand_tile_index: int = randi_range(0, cell_to_collapse.tile_options.size() - 1)
	var selected_tile: WfcTile = cell_to_collapse.tile_options[rand_tile_index]
	print("Choosing tile ", rand_tile_index, " out of ", cell_to_collapse.tile_options.size() - 1)
	selected_tile.print_info()
	cell_to_collapse.tile_options.append(selected_tile)
	
	var tile = selected_tile.model.instantiate()
	add_child(tile)
	tile.position = cell_to_collapse.position
	print("Collapsed cell at: ", tile.position.x, ", ", tile.position.z, " to be: ", selected_tile.resource_path)
	
	update_generation()


func update_generation():
	# Update what possible tiles are left for neighbors
	var new_generation_cells: Array[WfcCell] = grid_cells
	
	for y in range(0, dimensions):
		for x in range(0, dimensions):
			# The index of this 2D array
			var index = x + y * dimensions
			
			# If this cell is already collapsed, save it and move on
			if grid_cells[index].is_collapsed:
				new_generation_cells[index] = grid_cells[index]
			else:
				# Find all of our options for this cell
				var options = []
				for tile in tile_objects:
					options.append(tile)
				
				if y > 0:
					# Look at the cell above this one
					var up_cell: WfcCell = grid_cells[x + (y - 1) * dimensions]
					var valid_options = []
					
					# For each possible tile this cell could be, based on our up neighbor
					#for possible_option in up_cell.tile_options:
						## Find the index of this possible option in our overall options
						#for tile_index in range(0, tile_objects.size()):
							#if tile_objects[tile_index] == possible_option:
								#valid_options.append(tile_objects[tile_index].down_neighbors)
					
					check_validity(options, valid_options)


func check_validity(option_list, valid_option):
	pass
